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

    private var getData: String {
        let docRef = Firestore.firestore().collection("activities").document("2sh48Oovobha0cI1aWXZ")
        print("CURRENT USER ID ", String(describing: Auth.auth().currentUser?.uid));

        //        Auth.auth().addStateDidChangeListener { (auth, user) in
        //          if let user = user {
        //            let email = user.email
        //            // ...
        //          }
        //        }

        //        b. {
        //                    for document in querySnapshot!.documents {
        //                        print("\(document.documentID) => \(document.data())")
        //                    }
        //                }
        //        }


        return ""
    }

    var body: some View {
        NavigationView {
            switch (navigation.currentView) {
            case .LOGIN:
                VStack {
                    SecureField("Email", text: .constant(""))
                    SecureField("Password", text: .constant(""))
                    Text("Login Form")
                    Button("Login") {
                        navigation.currentView = .HOME
                    }
                }
            case .HOME:
                VStack {
                    Text("Home Page")
                }
            }
        }
    }
}

//
//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}

