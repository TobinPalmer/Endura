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
        //      .background(Color("SecondaryBackground"))
        .background(Color(red: 0.93, green: 0.95, blue: 0.97))
        .cornerRadius(6)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(hex: "D5D9DE"), lineWidth: 2)
        )
//        .shadow(color: Color(red: 0.2, green: 0.2, blue: 0.28).opacity(0.2), radius: 0.5, x: 0, y: 0)
//        .shadow(color: Color(red: 0.2, green: 0.2, blue: 0.28).opacity(0.08), radius: 1, x: 0, y: 1)
//      .foregroundColor(Color("InputText"))
    }
}
