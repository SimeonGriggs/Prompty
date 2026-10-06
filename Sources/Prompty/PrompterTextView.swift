import AppKit
import SwiftUI

struct PrompterTextView: NSViewRepresentable {
    let state: PrompterState

    func makeCoordinator() -> Coordinator {
        Coordinator(state: state)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSTextView.scrollableTextView()
        scrollView.drawsBackground = true
        scrollView.backgroundColor = .black
        scrollView.hasVerticalScroller = false
        scrollView.hasHorizontalScroller = false

        let textView = scrollView.documentView as! NSTextView
        textView.delegate = context.coordinator
        textView.isRichText = false
        textView.importsGraphics = false
        textView.allowsUndo = true
        textView.drawsBackground = true
        textView.backgroundColor = .black
        textView.textColor = .white
        textView.insertionPointColor = .white
        textView.selectedTextAttributes = [
            .backgroundColor: NSColor(white: 0.3, alpha: 1),
            .foregroundColor: NSColor.white,
        ]
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.textContainerInset = NSSize(width: 0, height: 60)
        textView.string = state.text

        context.coordinator.scrollView = scrollView
        context.coordinator.textView = textView
        context.coordinator.applyFont(state.font)
        context.coordinator.start()

        return scrollView
    }

    func updateNSView(_ scrollView: NSScrollView, context: Context) {
        let coordinator = context.coordinator
        if coordinator.textView?.font != state.font {
            coordinator.applyFont(state.font)
        }
        // Read so SwiftUI re-renders when playback toggles.
        _ = state.isPlaying
    }

    static func dismantleNSView(_ nsView: NSScrollView, coordinator: Coordinator) {
        coordinator.stop()
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        let state: PrompterState
        weak var scrollView: NSScrollView?
        weak var textView: NSTextView?

        private var timer: Timer?
        private var lastTick: CFTimeInterval = 0
        // Tracks sub-pixel progress so slow speeds don't get rounded away.
        private var offset: CGFloat = 0

        init(state: PrompterState) {
            self.state = state
        }

        func applyFont(_ font: NSFont) {
            guard let textView else { return }
            textView.font = font
            textView.typingAttributes = [.font: font, .foregroundColor: NSColor.white]
            textView.textColor = .white
        }

        func start() {
            lastTick = CACurrentMediaTime()
            let timer = Timer(timeInterval: 1.0 / 120.0, repeats: true) { [weak self] _ in
                MainActor.assumeIsolated { self?.tick() }
            }
            RunLoop.main.add(timer, forMode: .common)
            self.timer = timer
        }

        func stop() {
            timer?.invalidate()
            timer = nil
        }

        private func tick() {
            let now = CACurrentMediaTime()
            let delta = now - lastTick
            lastTick = now

            guard state.isPlaying,
                  let scrollView,
                  let documentView = scrollView.documentView
            else { return }

            let clipView = scrollView.contentView
            let currentY = clipView.bounds.origin.y
            if abs(currentY - offset) > 1 {
                offset = currentY
            }

            let maxY = max(0, documentView.frame.height - clipView.bounds.height)
            offset = min(offset + CGFloat(state.speed * delta), maxY)

            clipView.scroll(to: NSPoint(x: 0, y: offset))
            scrollView.reflectScrolledClipView(clipView)

            if offset >= maxY {
                state.isPlaying = false
            }
        }

        func textDidChange(_ notification: Notification) {
            guard let textView else { return }
            state.text = textView.string
        }
    }
}
