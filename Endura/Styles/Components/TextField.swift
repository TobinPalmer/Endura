import Foundation
import SwiftUI

struct EnduraTextFieldStyle: TextFieldStyle {
    private let systemImageString: String

    init(_ systemImageString: String = "") {
        self.systemImageString = systemImageString
    }

    func _body(configuration: TextField<Self._Label>) -> some View {
        HStack(alignment: .center, spacing: 0) {
            if !systemImageString.isEmpty {
                Image(systemName: systemImageString)
                    .foregroundColor(.gray)
            }

            configuration
        }
        .padding(.leading, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, minHeight: 36, maxHeight: 36, alignment: .leading)
        .accentColor(Color("InputText"))
        .foregroundColor(Color(red: 0.26, green: 0.33, blue: 0.4))
        .background(Color(red: 0.93, green: 0.95, blue: 0.97))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(hex: "D5D9DE"), lineWidth: 2)
        )
    }
}
