import Foundation

/// One calorie entry. Kept individually so "undo last" and a daily history are trivial.
struct Entry: Codable, Identifiable {
    let id: UUID
    let amount: Int
    let date: Date

    init(amount: Int, date: Date = Date()) {
        self.id = UUID()
        self.amount = amount
        self.date = date
    }
}

/// Persisted calorie log. Today's total is derived from entries dated today, so the
/// count rolls over to 0 at midnight automatically — no reset logic, and history is kept.
@MainActor
final class CalorieStore: ObservableObject {
    @Published private(set) var entries: [Entry] = []

    private let key = "calorie_entries_v1"
    private let calendar = Calendar.current

    init() { load() }

    var entriesForToday: [Entry] {
        entries.filter { calendar.isDateInToday($0.date) }
    }

    var todayTotal: Int {
        entriesForToday.reduce(0) { $0 + $1.amount }
    }

    /// Adjust today's total by a (possibly negative) delta, clamped so the total
    /// bottoms out at 0 (no hidden negative debt). Logged as an entry so undo works.
    func add(_ delta: Int) {
        let effective = max(0, todayTotal + delta) - todayTotal
        guard effective != 0 else { return }
        entries.append(Entry(amount: effective))
        save()
    }

    /// Remove the most recent entry from today.
    func undoLast() {
        guard let idx = entries.lastIndex(where: { calendar.isDateInToday($0.date) }) else { return }
        entries.remove(at: idx)
        save()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([Entry].self, from: data) else { return }
        entries = decoded
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(data, forKey: key)
    }
}
