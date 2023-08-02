//
// Created by Tobin Palmer on 7/17/23.
//

import Foundation
import SwiftUI

struct ProfileView: View {
    var body: some View {
        VStack {
            ProfileImage(AuthUtils.getCurrentUID(), size: 128)
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