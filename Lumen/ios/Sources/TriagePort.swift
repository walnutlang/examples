import Foundation
import NaturalLanguage
import WalnutUIKit

/// On-device note triage: NLEmbedding nearest-neighbor + keyword fallback.
/// Port.cmd "lumen.triage" — request `noteId=` / `text=`; reply OK + labels.
enum TriagePort {
    private struct Label {
        let kind: String
        let coach: String
        let commitment: String
        let summary: String
        let exemplars: [String]
    }

    private static let labels: [Label] = [
        Label(
            kind: "activity",
            coach: "coach-priya",
            commitment: "c1",
            summary: "Activity · noted for Priya",
            exemplars: [
                "I went for a walk",
                "ten minute walk after lunch",
                "I did a stroll around the block",
                "hit my step goal today",
                "movement after dinner",
            ]
        ),
        Label(
            kind: "activity",
            coach: "coach-priya",
            commitment: "c2",
            summary: "BP · noted for Priya",
            exemplars: [
                "logged morning blood pressure",
                "took my BP reading",
                "blood pressure before coffee",
            ]
        ),
        Label(
            kind: "food",
            coach: "coach-ava",
            commitment: "c3",
            summary: "Food · noted for Ava",
            exemplars: [
                "I just had Greek yogurt",
                "protein shake for breakfast",
                "ate eggs and toast",
                "had cottage cheese for lunch",
                "GLP-1 day quiet appetite meal",
            ]
        ),
        Label(
            kind: "glucose",
            coach: "coach-marcus",
            commitment: "",
            summary: "Glucose · noted for Marcus",
            exemplars: [
                "fasting glucose was high",
                "checked my blood sugar",
                "A1C discussion with clinician",
            ]
        ),
        Label(
            kind: "meds",
            coach: "coach-jordan",
            commitment: "",
            summary: "Meds · noted for Jordan",
            exemplars: [
                "took my statin with dinner",
                "cholesterol medication timing",
                "lipid panel questions",
            ]
        ),
        Label(
            kind: "general",
            coach: "coach-ava",
            commitment: "",
            summary: "Note · Ava has your update",
            exemplars: [
                "feeling tired today",
                "general check in about my week",
                "something on my mind",
            ]
        ),
    ]

    static func register() {
        WalnutPorts.registerCmd("lumen.triage") { payload, reply in
            let fields = parseFields(payload)
            let noteId = fields["noteId"] ?? ""
            let text = fields["text"] ?? ""
            guard !noteId.isEmpty, !text.isEmpty else {
                reply("ERR\nmissing noteId or text")
                return
            }
            let result = triage(text: text)
            reply(
                [
                    "OK",
                    "noteId=\(noteId)",
                    "kind=\(result.kind)",
                    "coach=\(result.coach)",
                    "commitment=\(result.commitment)",
                    "summary=\(result.summary)",
                ].joined(separator: "\n")
            )
        }
    }

    private static func triage(text: String) -> (kind: String, coach: String, commitment: String, summary: String) {
        if let embedded = embedTriage(text: text) {
            return embedded
        }
        return keywordTriage(text: text)
    }

    private static func embedTriage(text: String) -> (kind: String, coach: String, commitment: String, summary: String)? {
        guard let embedding = NLEmbedding.wordEmbedding(for: .english) else {
            return nil
        }
        let query = averageVector(for: text, embedding: embedding)
        guard !query.isEmpty else { return nil }

        var best: (score: Double, label: Label)?
        for label in labels {
            for exemplar in label.exemplars {
                let vec = averageVector(for: exemplar, embedding: embedding)
                guard !vec.isEmpty else { continue }
                let score = cosine(query, vec)
                if best == nil || score > best!.score {
                    best = (score, label)
                }
            }
        }
        guard let winner = best, winner.score > 0.15 else { return nil }
        return (winner.label.kind, winner.label.coach, winner.label.commitment, winner.label.summary)
    }

    private static func averageVector(for text: String, embedding: NLEmbedding) -> [Double] {
        let tokens = text.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        var sum: [Double] = []
        var count = 0
        for token in tokens {
            guard let vector = embedding.vector(for: token) else { continue }
            if sum.isEmpty {
                sum = vector
            } else if sum.count == vector.count {
                for i in 0..<sum.count {
                    sum[i] += vector[i]
                }
            }
            count += 1
        }
        guard count > 0 else { return [] }
        return sum.map { $0 / Double(count) }
    }

    private static func cosine(_ a: [Double], _ b: [Double]) -> Double {
        guard a.count == b.count, !a.isEmpty else { return -1 }
        var dot = 0.0
        var na = 0.0
        var nb = 0.0
        for i in 0..<a.count {
            dot += a[i] * b[i]
            na += a[i] * a[i]
            nb += b[i] * b[i]
        }
        let denom = sqrt(na) * sqrt(nb)
        guard denom > 0 else { return -1 }
        return dot / denom
    }

    private static func keywordTriage(text: String) -> (kind: String, coach: String, commitment: String, summary: String) {
        let blob = text.lowercased()
        if blob.contains("walk") || blob.contains("stroll") || blob.contains("steps") {
            return ("activity", "coach-priya", "c1", "Activity · noted for Priya")
        }
        if blob.contains("pressure") || blob.contains(" bp") || blob.contains("bp ") || blob.hasPrefix("bp") {
            return ("activity", "coach-priya", "c2", "BP · noted for Priya")
        }
        if blob.contains("glucose") || blob.contains("sugar") || blob.contains("a1c") {
            return ("glucose", "coach-marcus", "", "Glucose · noted for Marcus")
        }
        if blob.contains("statin") || blob.contains("cholesterol") || blob.contains("lipid") {
            return ("meds", "coach-jordan", "", "Meds · noted for Jordan")
        }
        if blob.contains("protein") || blob.contains("yogurt") || blob.contains("breakfast")
            || blob.contains("ate ") || blob.contains("had ") || blob.contains("meal") || blob.contains("glp")
        {
            return ("food", "coach-ava", "c3", "Food · noted for Ava")
        }
        return ("general", "coach-ava", "", "Note · Ava has your update")
    }

    private static func parseFields(_ payload: String) -> [String: String] {
        var out: [String: String] = [:]
        for line in payload.split(separator: "\n", omittingEmptySubsequences: false) {
            let s = String(line)
            guard let eq = s.firstIndex(of: "=") else { continue }
            let key = String(s[..<eq])
            let value = String(s[s.index(after: eq)...])
            out[key] = value
        }
        return out
    }
}
