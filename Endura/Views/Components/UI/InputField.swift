//
// Created by Tobin Palmer on 8/2/23.
//

import Foundation
import SwiftUI

import SwiftUI

struct LoginTextInput: View {
    private let placeholder: String
    private let text: Binding<String>
    private let secure: Bool

    init(_ placeholder: String, _ text: Binding<String>, secure: Bool = false) {
        self.placeholder = placeholder
        self.text = text
        self.secure = secure
    }

    public var body: some View {
        if secure {
            SecureField(placeholder, text: text)
                .padding(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.black, lineWidth: 2)
                )
        } else {
            TextField(placeholder, text: text)
                .padding(20)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(.black, lineWidth: 2)
                )
        }
    }
}
