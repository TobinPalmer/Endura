//
// Created by Tobin Palmer on 7/17/23.
//

import Foundation
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var navigation: NavigationModel;

    var body: some View {
        VStack {
            Text("Home Page")
            Button("Go To Login") {
                navigation.currentView = .LOGIN
            }
        }
    }
}