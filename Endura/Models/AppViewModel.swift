//
// Created by Tobin Palmer on 7/16/23.
//

import Foundation

enum PageView {
    case HOME
    case LOGIN
}

class NavigationModel: ObservableObject {
    class var instance: NavigationModel {
        struct Singleton {
            static let instance = NavigationModel()
        }

        return Singleton.instance
    }

    @Published var currentView: PageView = .LOGIN
}