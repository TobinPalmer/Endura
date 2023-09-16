import Foundation

public enum PageView {
    case HOME
    case LOGIN
}

public final class NavigationModel: ObservableObject {
    public final class var instance: NavigationModel {
        enum Singleton {
            static let instance = NavigationModel()
        }

        return Singleton.instance
    }

    private init() {}

    @Published var currentView: PageView = .LOGIN {
        didSet {
            refreshID = UUID()
        }
    }

    @Published var refreshID: UUID = .init()
}
