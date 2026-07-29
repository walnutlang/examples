import Foundation
import MLX
import MLXEmbedders
import Tokenizers
import WalnutUIKit

/// Host port for on-device embeddings (`Port.cmd "mlx.rank"`).
///
/// Model: `TaylorAI/bge-micro-v2` via MLXEmbedders — smallest stock config (~17M).
enum EmbedPort {
    private static let lock = NSLock()
    private static var container: ModelContainer?
    private static var loadError: String?
    private static var loading = false

    static func register() {
        startLoadIfNeeded()
        WalnutPorts.registerCmd("mlx.rank") { payload, reply in
            Task {
                let out = await handle(payload: payload)
                reply(out)
            }
        }
    }

    private static func startLoadIfNeeded() {
        lock.lock()
        if container != nil || loading || loadError != nil {
            lock.unlock()
            return
        }
        loading = true
        lock.unlock()

        Task {
            do {
                let loaded = try await loadModelContainer(configuration: .bge_micro)
                lock.lock()
                container = loaded
                loading = false
                lock.unlock()
            } catch {
                lock.lock()
                loadError = error.localizedDescription
                loading = false
                lock.unlock()
            }
        }
    }

    private static func snapshot() -> (ModelContainer?, String?, Bool) {
        lock.lock()
        defer { lock.unlock() }
        return (container, loadError, loading)
    }

    private static func handle(payload: String) async -> String {
        startLoadIfNeeded()
        let (ready, err, busy) = snapshot()
        let trimmed = payload.trimmingCharacters(in: .whitespacesAndNewlines)

        if trimmed.isEmpty {
            if ready != nil { return "READY" }
            if let err { return "ERR\n\(err)" }
            if busy { return "LOADING" }
            return "LOADING"
        }

        if let err { return "ERR\n\(err)" }
        guard let container = ready else { return "LOADING" }

        let parts = trimmed.components(separatedBy: "\n---\n")
        guard parts.count >= 2 else {
            return "ERR\nexpected query\\n---\\ncorpus lines"
        }
        let query = parts[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let corpus = parts[1]
            .split(separator: "\n", omittingEmptySubsequences: false)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        guard !query.isEmpty else { return "ERR\nempty query" }
        guard !corpus.isEmpty else { return "ERR\nempty corpus" }

        let texts = [query] + corpus
        let vectors = await embed(texts: texts, container: container)
        guard let q = vectors.first, vectors.count == texts.count else {
            return "ERR\nembed size mismatch"
        }

        var ranked: [(Float, String)] = []
        ranked.reserveCapacity(corpus.count)
        for i in 0..<corpus.count {
            ranked.append((cosine(q, vectors[i + 1]), corpus[i]))
        }
        ranked.sort { $0.0 > $1.0 }

        var lines = ["OK"]
        for (score, text) in ranked {
            let clamped = max(-1 as Float, min(1, score))
            lines.append(String(format: "%.4f\t%@", clamped, text))
        }
        return lines.joined(separator: "\n")
    }

    private static func embed(texts: [String], container: ModelContainer) async -> [[Float]] {
        await container.perform {
            (model: EmbeddingModel, tokenizer: Tokenizer, pooling: Pooling) -> [[Float]] in
            let inputs = texts.map {
                tokenizer.encode(text: $0, addSpecialTokens: true)
            }
            let maxLength = inputs.reduce(into: 16) { acc, elem in
                acc = max(acc, elem.count)
            }
            let padId = tokenizer.eosTokenId ?? 0
            let padded = stacked(
                inputs.map { elem in
                    MLXArray(elem + Array(repeating: padId, count: maxLength - elem.count))
                })
            let mask = (padded .!= padId)
            let tokenTypes = MLXArray.zeros(like: padded)
            let pooled = pooling(
                model(
                    padded,
                    positionIds: nil,
                    tokenTypeIds: tokenTypes,
                    attentionMask: mask
                ),
                normalize: true,
                applyLayerNorm: true
            )
            pooled.eval()
            return pooled.map { $0.asArray(Float.self) }
        }
    }

    private static func cosine(_ a: [Float], _ b: [Float]) -> Float {
        let n = min(a.count, b.count)
        guard n > 0 else { return 0 }
        var dot: Float = 0
        var na: Float = 0
        var nb: Float = 0
        for i in 0..<n {
            dot += a[i] * b[i]
            na += a[i] * a[i]
            nb += b[i] * b[i]
        }
        let denom = (na.squareRoot() * nb.squareRoot())
        guard denom > 0 else { return 0 }
        return dot / denom
    }
}
