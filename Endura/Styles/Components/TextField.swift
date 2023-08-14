//
// Created by Tobin Palmer on 8/13/23.
//

import Foundation
import SwiftUI

struct EnduraTextFieldStyle: TextFieldStyle {
    private let systemImageString: String

    init(_ systemImageString: String = "") {
        self.systemImageString = systemImageString
    }

    func _body(configuration: TextField<Self._Label>) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5.0)
                .stroke(
                    LinearGradient(
                        colors: [
                            .red,
                            .blue,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 40)

            HStack {
                if !systemImageString.isEmpty {
                    Image(systemName: systemImageString)
                        .foregroundColor(.gray)
                }

                configuration
            }
            .padding(.leading)
            .foregroundColor(.gray)
        }
    }
}
