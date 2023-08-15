//
// Created by Tobin Palmer on 8/14/23.
//

import Foundation
import SwiftUI

public struct EnduraButtonStyle: ButtonStyle {
    private let disabled: Bool

    init(disabled: Bool = false) {
        self.disabled = disabled
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(disabled ? Color.gray : Color.blue)
            .animation(.easeInOut(duration: 0.1), value: disabled)
            .foregroundColor(.white)
            .cornerRadius(5)
    }
}
