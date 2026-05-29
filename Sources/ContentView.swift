import SwiftUI

/// Six quick-adjust buttons (+1/-1, +10/-10, +11/-11) over today's total.
/// Tap to log instantly; long-press the total to undo the last tap.
struct ContentView: View {
    @EnvironmentObject private var store: CalorieStore

    private let deltas = [1, 10, 11]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 5), count: 3)

    var body: some View {
        VStack(spacing: 6) {
            VStack(spacing: 0) {
                Text("\(store.todayTotal)")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
                    .contentTransition(.numericText())
                    .animation(.snappy, value: store.todayTotal)
                Text("kcal today")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .onLongPressGesture { store.undoLast() } // undo last tap

            // + row, then - row
            LazyVGrid(columns: columns, spacing: 5) {
                ForEach(deltas, id: \.self) { d in deltaButton(d) }
                ForEach(deltas, id: \.self) { d in deltaButton(-d) }
            }
        }
        .padding(.horizontal, 3)
    }

    private func deltaButton(_ delta: Int) -> some View {
        Button { store.add(delta) } label: {
            Text(delta > 0 ? "+\(delta)" : "\(delta)")
                .font(.headline)
                .monospacedDigit()
                .frame(maxWidth: .infinity, minHeight: 38)
        }
        .buttonStyle(.bordered)
        .tint(delta > 0 ? .green : .orange)
    }
}

#Preview {
    ContentView().environmentObject(CalorieStore())
}
