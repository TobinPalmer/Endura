//
// Created by Tobin Palmer on 7/17/23.
//

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseAuth
import HealthKit

struct DashboardView: View {
    @EnvironmentObject var navigation: NavigationModel
    @State private var activities: [Activity] = []
    @State private var uploads: [HKWorkout?] = []

    var body: some View {
        VStack {
            Text("Content")
        }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    NavigationLink(destination: UploadWorkoutView()) {
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.orange)
                    }
                        .buttonStyle(PlainButtonStyle())
                }
            }

        //        VStack {
        //            HStack {
        //                NavigationLink(destination: UploadWorkoutView()) {
        //                    Image(systemName: "plus")
        //                        .font(.title)
        //                        .fontWeight(.bold)
        //                }
        //                    .padding(.trailing, 20);
        //            }
        //                .frame(height: 50)
        //            Text("content")
        //            Spacer()
        //        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(NavigationModel.instance)
    }
}
