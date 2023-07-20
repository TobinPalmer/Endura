//
//  ContentView.swift
//  Endura
//
//  Created by Tobin Palmer on 7/15/23.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct ContentView: View {
    @EnvironmentObject var navigation: NavigationModel;

    var body: some View {
        switch (navigation.currentView) {
        case .LOGIN:
            LoginView()
        case .HOME:
            HomeView()
        }
    }
}
