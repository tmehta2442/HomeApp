import Foundation
import Observation

struct Visitor: Identifiable, Codable {
    var id = UUID()
    var firstName: String
    var lastName: String
    var phone: String
    var email: String
    var hasAgent: Bool
    var agentName: String
    var agentBrokerage: String
    var agentPhone: String
    var timestamp: Date
    var deletedAt: Date? = nil

    var fullName: String { "\(firstName) \(lastName)" }
}

@Observable
class DataStore {
    var visitors: [Visitor] = []
    var deletedVisitors: [Visitor] = []

    private let saveURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("visitors.json")
    }()

    private let deletedURL: URL = {
        FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("deleted_visitors.json")
    }()

    init() {
        load()
        loadDeleted()
        purgeExpired()
    }

    // MARK: - Active visitors

    func add(_ visitor: Visitor) {
        visitors.insert(visitor, at: 0)
        save()
        appendToTextFile(visitor)
    }

    func softDelete(_ visitor: Visitor) {
        if let index = visitors.firstIndex(where: { $0.id == visitor.id }) {
            softDelete(at: IndexSet([index]))
        }
    }

    func softDelete(at offsets: IndexSet) {
        for index in offsets {
            var v = visitors[index]
            v.deletedAt = Date()
            deletedVisitors.insert(v, at: 0)
        }
        visitors.remove(atOffsets: offsets)
        save()
        saveDeleted()
    }

    // MARK: - Recently deleted

    func restore(_ visitor: Visitor) {
        deletedVisitors.removeAll { $0.id == visitor.id }
        var v = visitor
        v.deletedAt = nil
        visitors.insert(v, at: 0)
        save()
        saveDeleted()
    }

    func permanentlyDelete(at offsets: IndexSet) {
        deletedVisitors.remove(atOffsets: offsets)
        saveDeleted()
    }

    // MARK: - Persistence

    private func purgeExpired() {
        let cutoff = Date().addingTimeInterval(-30 * 24 * 60 * 60)
        deletedVisitors.removeAll { ($0.deletedAt ?? .distantPast) < cutoff }
        saveDeleted()
    }

    private func save() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(visitors) {
            try? data.write(to: saveURL)
        }
    }

    private func load() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = try? Data(contentsOf: saveURL),
           let decoded = try? decoder.decode([Visitor].self, from: data) {
            visitors = decoded
        }
    }

    private func saveDeleted() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        if let data = try? encoder.encode(deletedVisitors) {
            try? data.write(to: deletedURL)
        }
    }

    private func loadDeleted() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        if let data = try? Data(contentsOf: deletedURL),
           let decoded = try? decoder.decode([Visitor].self, from: data) {
            deletedVisitors = decoded
        }
    }

    // MARK: - Text file

    func appendToTextFile(_ visitor: Visitor) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short

        var lines: [String] = []
        lines.append("")
        lines.append("========================================")
        lines.append("  HOME VIEWING SIGN-IN")
        lines.append("  \(dateFormatter.string(from: visitor.timestamp))")
        lines.append("========================================")
        lines.append("")

        let name = "\(visitor.firstName) \(visitor.lastName)".trimmed
        if !name.isEmpty  { lines.append("  Name:     \(name)") }
        if !visitor.phone.isEmpty { lines.append("  Phone:    \(visitor.phone)") }
        if !visitor.email.isEmpty { lines.append("  Email:    \(visitor.email)") }

        if visitor.hasAgent {
            lines.append("")
            lines.append("  Working with an Agent:")
            if !visitor.agentName.isEmpty      { lines.append("    Agent:     \(visitor.agentName)") }
            if !visitor.agentBrokerage.isEmpty { lines.append("    Brokerage: \(visitor.agentBrokerage)") }
            if !visitor.agentPhone.isEmpty     { lines.append("    Phone:     \(visitor.agentPhone)") }
        } else {
            lines.append("")
            lines.append("  No agent.")
        }

        lines.append("")

        let entry = lines.joined(separator: "\n") + "\n"
        let textURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Home Viewing Sign-Ins.txt")

        if let data = entry.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: textURL.path) {
                if let handle = try? FileHandle(forWritingTo: textURL) {
                    handle.seekToEndOfFile()
                    handle.write(data)
                    try? handle.close()
                }
            } else {
                try? data.write(to: textURL)
            }
        }
    }
}

extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
