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
                    .font(.system(size: 22))
                    .frame(width: 52, height: 52)
                    .overlay(Circle().stroke(lineWidth: 1.5))
                    .contentShape(Circle())
            }
            .keyboardShortcut(.return, modifiers: .command)
            .help("Play / Pause (⌘↩)")

            VStack(spacing: 40) {
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
            .opacity(state.isPlaying ? 0 : 1)
            .allowsHitTesting(!state.isPlaying)
            .animation(.easeInOut(duration: 0.4), value: state.isPlaying)
        }
        .buttonStyle(.plain)
        .foregroundStyle(Color.buttonGrey)
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

            CircleButton(systemName: "plus", action: increment)
                .keyboardShortcut(incrementShortcut)

            Text(value)
                .font(.system(size: 16, weight: .medium).monospacedDigit())

            CircleButton(systemName: "minus", action: decrement)
                .keyboardShortcut(decrementShortcut)
        }
    }
}

private struct CircleButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 34, height: 34)
                .overlay(Circle().stroke(lineWidth: 1.5))
                .contentShape(Circle())
        }
    }
}

private extension Color {
    static let buttonGrey = Color(white: 0.45)
}
