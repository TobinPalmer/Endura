import Foundation
import SwiftUI

struct PageWidgetView<Content: View>: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        VStack {
            VStack {
                content()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .enduraDefaultBox()
        }
        .padding(10)
        .padding(.bottom, 20)
    }
}
