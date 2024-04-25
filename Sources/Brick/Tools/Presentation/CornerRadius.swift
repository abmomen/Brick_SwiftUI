import SwiftUI

@available(iOS, deprecated: 16.4)
@available(tvOS, deprecated: 16.4)
@available(macOS, deprecated: 13.3)
@available(watchOS, deprecated: 9.4)
public extension Brick where Wrapped: View {
    @ViewBuilder
    func presentationCornerRadius(_ cornerRadius: CGFloat?) -> some View {
#if os(iOS) || targetEnvironment(macCatalyst)
        if #available(iOS 15, *) {
            wrapped.background(Brick<Any>.Representable(cornerRadius: cornerRadius))
        } else {
            wrapped
        }

#else
        wrapped
#endif
    }
}

#if os(iOS) || targetEnvironment(macCatalyst)
@available(iOS 15, *)
private extension Brick where Wrapped == Any {
    struct Representable: UIViewControllerRepresentable {
        let cornerRadius: CGFloat?

        func makeUIViewController(context: Context) -> Brick.Representable.Controller {
            Controller(cornerRadius: cornerRadius)
        }

        func updateUIViewController(_ controller: Brick.Representable.Controller, context: Context) {
            controller.update(cornerRadius: cornerRadius)
        }
    }
}
@available(iOS 15, *)
private extension Brick.Representable {
    final class Controller: UIViewController, UISheetPresentationControllerDelegate {
        var cornerRadius: CGFloat?

        init(cornerRadius: CGFloat?) {
            self.cornerRadius = cornerRadius
            super.init(nibName: nil, bundle: nil)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func willMove(toParent parent: UIViewController?) {
            super.willMove(toParent: parent)
            update(cornerRadius: cornerRadius)
        }

        override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
            super.willTransition(to: newCollection, with: coordinator)
            update(cornerRadius: cornerRadius)
        }

        func update(cornerRadius: CGFloat?) {
            self.cornerRadius = cornerRadius

            if let controller = parent?.sheetPresentationController {
                controller.animateChanges {
                    controller.preferredCornerRadius = cornerRadius
                }
            }
        }
    }
}
#endif
