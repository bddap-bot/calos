import SwiftUI

/// The whole app: a numeric keypad so entry is numbers-only and fast.
/// Tap digits → the big number; ✓ adds it to today's total. ⌫ deletes a digit.
/// Long-press the total to undo the last entry.
struct ContentView: View {
    @EnvironmentObject private var store: CalorieStore
    @State private var entry = ""

    private let keys = ["1","2","3","4","5","6","7","8","9","⌫","0","✓"]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)

    var body: some View {
        VStack(spacing: 4) {
            // Header: today's total (long-press = undo) + what you're typing.
            HStack(alignment: .firstTextBaseline) {
                Text("\(store.todayTotal)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: store.todayTotal)
                Text("kcal")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                Spacer()
                Text(entry.isEmpty ? "0" : entry)
                    .font(.title2.weight(.bold))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
            .onLongPressGesture { store.undoLast() } // undo last entry

            LazyVGrid(columns: columns, spacing: 4) {
                ForEach(keys, id: \.self) { key in
                    Button { tap(key) } label: {
                        Text(key)
                            .font(.title3)
                            .frame(maxWidth: .infinity, minHeight: 34)
                    }
                    .buttonStyle(.bordered)
                    .tint(tint(for: key))
                    .disabled(key == "✓" && (Int(entry) ?? 0) <= 0)
                }
            }
        }
        .padding(.horizontal, 2)
    }

    private func tint(for key: String) -> Color {
        switch key {
        case "✓": return .green
        case "⌫": return .orange
        default: return .gray
        }
    }

    private func tap(_ key: String) {
        switch key {
        case "⌫":
            if !entry.isEmpty { entry.removeLast() }
        case "✓":
            if let n = Int(entry), n > 0 { store.add(n) }
            entry = ""
        default: // a digit
            if entry.count < 5 { entry += key } // cap at 99999
            if entry == "0" { entry = "" }       // no leading zero
        }
    }
}

#Preview {
    ContentView().environmentObject(CalorieStore())
}
