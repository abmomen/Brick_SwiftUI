#if os(iOS)
import SwiftUI

struct ToolbarViews {
    var navigationBar: AnyView?
    var bottomBar: AnyView?
    var tabBar: AnyView?
}

struct ToolbarVisibility {
    var navigationBar: Brick<Any>.Visibility?
    var bottomBar: Brick<Any>.Visibility?
    var tabBar: Brick<Any>.Visibility?
}

private struct ToolbarViewsKey: EnvironmentKey {
    static var defaultValue: ToolbarViews = .init()
}

private struct ToolbarVisibilityKey: EnvironmentKey {
    static var defaultValue: ToolbarVisibility = .init()
}

internal extension EnvironmentValues {
    var toolbarViews: ToolbarViews {
        get { self[ToolbarViewsKey.self] }
        set { self[ToolbarViewsKey.self] = newValue }
    }
}

internal extension EnvironmentValues {
    var toolbarVisibility: ToolbarVisibility {
        get { self[ToolbarVisibilityKey.self] }
        set { self[ToolbarVisibilityKey.self] = newValue }
    }
}
#endif
