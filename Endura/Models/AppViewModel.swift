//
// Created by Tobin Palmer on 7/16/23.
//

import Foundation

enum PageView {
    case HOME
    case LOGIN
}

class NavigationModel: ObservableObject {
    @Published var currentView: PageView = .LOGIN
}