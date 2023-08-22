import Foundation
import SwiftUI

struct LoadingMap: View {
    private let height: CGFloat

    public init(height: CGFloat = 300) {
        self.height = height
    }

    public var body: some View {
        VStack {
            VStack {
                Text("Loading...")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .frame(height: height)
            .foregroundColor(Color.red)
            .border(.red)
        }
    }
}
