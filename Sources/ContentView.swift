import SwiftUI

/// The whole app: today's total up top, a focused number field, Add + Undo.
/// Primary story: open app → field is already focused → type a number → Add.
struct ContentView: View {
    @EnvironmentObject private var store: CalorieStore
    @State private var input = ""
    @FocusState private var focused: Bool

    private var parsed: Int? {
        let n = Int(input.trimmingCharacters(in: .whitespaces))
        return (n ?? 0) > 0 ? n : nil
    }

    var body: some View {
        VStack(spacing: 6) {
            Text("\(store.todayTotal)")
                .font(.system(size: 46, weight: .bold, design: .rounded))
                .minimumScaleFactor(0.4)
                .lineLimit(1)
                .contentTransition(.numericText())
                .animation(.snappy, value: store.todayTotal)

            Text("kcal today")
                .font(.caption2)
                .foregroundStyle(.secondary)

            TextField("add", text: $input)
                .focused($focused)
                .multilineTextAlignment(.center)
                .font(.title3.weight(.semibold))
                .onSubmit(add)

            HStack(spacing: 6) {
                Button(action: store.undoLast) {
                    Image(systemName: "arrow.uturn.backward")
                }
                .tint(.gray)
                .disabled(store.entriesForToday.isEmpty)
                .fixedSize()

                Button(action: add) {
                    Text("Add").frame(maxWidth: .infinity)
                }
                .tint(.green)
                .disabled(parsed == nil)
            }
        }
        .padding(.horizontal, 2)
        .onAppear { focused = true }
    }

    private func add() {
        guard let n = parsed else { return }
        store.add(n)
        input = ""
        focused = true // stay ready for the next entry
    }
}

#Preview {
    ContentView().environmentObject(CalorieStore())
}
