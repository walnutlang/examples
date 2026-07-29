import Foundation
import HealthKit
import WalnutUIKit

/// HealthKit port: authorize + summary query (device). Simulator returns stub vitals.
enum HealthKitPort {
    private static let store: HKHealthStore? = HKHealthStore.isHealthDataAvailable() ? HKHealthStore() : nil

    static func register() {
        WalnutPorts.registerCmd("healthkit.authorize") { payload, reply in
            authorize(typesCSV: payload, reply: reply)
        }
        WalnutPorts.registerCmd("healthkit.query") { payload, reply in
            if payload == "summary" || payload.hasPrefix("summary") {
                querySummary(reply: reply)
            } else {
                reply("ERR\nunknown query")
            }
        }
    }

    private static func authorize(typesCSV: String, reply: @escaping (String) -> Void) {
        guard let store else {
            reply("stub:ok")
            return
        }
        let read = sampleTypes(from: typesCSV)
        store.requestAuthorization(toShare: [], read: read) { ok, error in
            DispatchQueue.main.async {
                if let error {
                    reply("denied:\(error.localizedDescription)")
                } else if ok {
                    reply("ok")
                } else {
                    reply("denied")
                }
            }
        }
    }

    private static func querySummary(reply: @escaping (String) -> Void) {
        guard let store else {
            reply(Self.stubSummary(sourceNote: "stub"))
            return
        }
        let group = DispatchGroup()
        var steps = 0
        var hr = 0
        var glucose = 0
        var bpSys = 0
        var bpDia = 0
        var weight = 0

        group.enter()
        stepsToday(store: store) { steps = $0; group.leave() }
        group.enter()
        latestQuantity(store: store, type: .heartRate, unit: HKUnit.count().unitDivided(by: .minute())) {
            hr = Int($0.rounded()); group.leave()
        }
        group.enter()
        latestQuantity(store: store, type: .bloodGlucose, unit: HKUnit(from: "mg/dL")) {
            glucose = Int($0.rounded()); group.leave()
        }
        group.enter()
        latestQuantity(store: store, type: .bodyMass, unit: .pound()) {
            weight = Int($0.rounded()); group.leave()
        }
        group.enter()
        latestBloodPressure(store: store) { s, d in bpSys = s; bpDia = d; group.leave() }

        group.notify(queue: .main) {
            let body = [
                "steps=\(steps)",
                "hr=\(hr)",
                "glucose=\(glucose)",
                "bpSys=\(bpSys)",
                "bpDia=\(bpDia)",
                "weight=\(weight)",
            ].joined(separator: "\n")
            reply(body)
        }
    }

    private static func stubSummary(sourceNote: String) -> String {
        [
            "steps=6420",
            "hr=72",
            "glucose=118",
            "bpSys=128",
            "bpDia=82",
            "weight=178",
            "note=\(sourceNote)",
        ].joined(separator: "\n")
    }

    private static func sampleTypes(from csv: String) -> Set<HKObjectType> {
        var set = Set<HKObjectType>()
        for raw in csv.split(separator: ",") {
            switch raw.trimmingCharacters(in: .whitespaces) {
            case "steps":
                if let t = HKObjectType.quantityType(forIdentifier: .stepCount) { set.insert(t) }
            case "heartRate":
                if let t = HKObjectType.quantityType(forIdentifier: .heartRate) { set.insert(t) }
            case "bloodPressure":
                if let s = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic) { set.insert(s) }
                if let d = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic) { set.insert(d) }
            case "bloodGlucose":
                if let t = HKObjectType.quantityType(forIdentifier: .bloodGlucose) { set.insert(t) }
            case "bodyMass":
                if let t = HKObjectType.quantityType(forIdentifier: .bodyMass) { set.insert(t) }
            default:
                break
            }
        }
        return set
    }

    private static func stepsToday(store: HKHealthStore, done: @escaping (Int) -> Void) {
        guard let type = HKQuantityType.quantityType(forIdentifier: .stepCount) else {
            done(0); return
        }
        let start = Calendar.current.startOfDay(for: Date())
        let pred = HKQuery.predicateForSamples(withStart: start, end: Date())
        let q = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: pred, options: .cumulativeSum) { _, stats, _ in
            let v = stats?.sumQuantity()?.doubleValue(for: .count()) ?? 0
            done(Int(v.rounded()))
        }
        store.execute(q)
    }

    private static func latestQuantity(
        store: HKHealthStore,
        type id: HKQuantityTypeIdentifier,
        unit: HKUnit,
        done: @escaping (Double) -> Void
    ) {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else {
            done(0); return
        }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let q = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            let v = (samples?.first as? HKQuantitySample)?.quantity.doubleValue(for: unit) ?? 0
            done(v)
        }
        store.execute(q)
    }

    private static func latestBloodPressure(store: HKHealthStore, done: @escaping (Int, Int) -> Void) {
        guard let type = HKCorrelationType.correlationType(forIdentifier: .bloodPressure) else {
            done(0, 0); return
        }
        let sort = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let q = HKSampleQuery(sampleType: type, predicate: nil, limit: 1, sortDescriptors: [sort]) { _, samples, _ in
            guard let corr = samples?.first as? HKCorrelation,
                  let sysT = HKQuantityType.quantityType(forIdentifier: .bloodPressureSystolic),
                  let diaT = HKQuantityType.quantityType(forIdentifier: .bloodPressureDiastolic),
                  let sys = corr.objects(for: sysT).first as? HKQuantitySample,
                  let dia = corr.objects(for: diaT).first as? HKQuantitySample
            else {
                done(0, 0); return
            }
            let unit = HKUnit.millimeterOfMercury()
            done(Int(sys.quantity.doubleValue(for: unit).rounded()),
                 Int(dia.quantity.doubleValue(for: unit).rounded()))
        }
        store.execute(q)
    }
}
