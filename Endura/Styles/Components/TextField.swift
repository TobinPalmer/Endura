//
// Created by Tobin Palmer on 8/13/23.
//

import Foundation
import SwiftUI

struct EnduraTextFieldStyle: TextFieldStyle {

    let systemImageString: String

    func _body(configuration: TextField<Self._Label>) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5.0)
                .stroke(
                        LinearGradient(
                                colors: [
                                    .red,
                                    .blue
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                        )
                )
                .frame(height: 40)

            HStack {
                Image(systemName: systemImageString)
                // Reference the TextField here
                configuration
            }
                .padding(.leading)
                .foregroundColor(.gray)
        }
    }
}
