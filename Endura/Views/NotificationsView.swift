//
// Created by Tobin Palmer on 9/2/23.
//

import Foundation

import SwiftUI

fileprivate final class NotificationsViewModel: ObservableObject {
}

struct NotificationsView: View {
  @StateObject private var viewModel = NotificationsViewModel()

  public var body: some View {
    VStack {
      Text("Notifications View")
    }
  }
}
