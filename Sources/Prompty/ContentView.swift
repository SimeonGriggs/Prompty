import SwiftUI

struct ContentView: View {
    @State private var state = PrompterState()

    private let sideColumnWidth: CGFloat = 140

    var body: some View {
        HStack(spacing: 0) {
            Color.black
                .frame(width: sideColumnWidth)

            PrompterTextView(state: state)
                .frame(maxWidth: state.columnWidth)
                .frame(maxWidth: .infinity)

            ControlsColumn(state: state)
                .frame(width: sideColumnWidth)
        }
        .background(Color.black)
        .ignoresSafeArea()
    }
}

struct ControlsColumn: View {
    let state: PrompterState

    var body: some View {
        VStack(spacing: 40) {
            Button {
                state.isPlaying.toggle()
            } label: {
                Image(systemName: state.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 40))
                    .frame(width: 80, height: 80)
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
            }
            .keyboardShortcut(.return, modifiers: .command)
            .help("Play / Pause (⌘↩)")

            Stepper(
                title: "Speed",
                value: "\(Int(state.speed))",
                increment: state.faster,
                decrement: state.slower,
                incrementShortcut: KeyboardShortcut(.upArrow, modifiers: .command),
                decrementShortcut: KeyboardShortcut(.downArrow, modifiers: .command)
            )

            Stepper(
                title: "Size",
                value: "\(Int(state.fontSize))",
                increment: state.larger,
                decrement: state.smaller,
                incrementShortcut: KeyboardShortcut("=", modifiers: .command),
                decrementShortcut: KeyboardShortcut("-", modifiers: .command)
            )
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.white)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
    }
}

private struct Stepper: View {
    let title: String
    let value: String
    let increment: () -> Void
    let decrement: () -> Void
    let incrementShortcut: KeyboardShortcut
    let decrementShortcut: KeyboardShortcut

    var body: some View {
        VStack(spacing: 10) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .semibold))
                .tracking(1.5)

            Button(action: increment) {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 50, height: 50)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
            }
            .keyboardShortcut(incrementShortcut)

            Text(value)
                .font(.system(size: 16, weight: .medium).monospacedDigit())

            Button(action: decrement) {
                Image(systemName: "minus")
                    .font(.system(size: 22, weight: .semibold))
                    .frame(width: 50, height: 50)
                    .overlay(Circle().stroke(Color.white, lineWidth: 1.5))
            }
            .keyboardShortcut(decrementShortcut)
        }
        .contentShape(Rectangle())
    }
}
