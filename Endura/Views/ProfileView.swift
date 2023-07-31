//
// Created by Tobin Palmer on 7/17/23.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            Text("Profile View")
        }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: SettingsView()) {
                        Image(systemName: "gearshape")
                    }
                }
            }
    }
}