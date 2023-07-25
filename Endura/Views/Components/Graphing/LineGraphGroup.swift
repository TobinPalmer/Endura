//
// Created by Tobin Palmer on 7/24/23.
//

import Foundation
import SwiftUI

class LineGraphViewModel: ObservableObject {
    @Published var touchLocationX: CGFloat? = nil
}


public struct LineGraphGroup<Content: View>: View {
    private let graphs: Content
    @EnvironmentObject var viewModel: LineGraphViewModel

    public init(@ViewBuilder graphs: () -> Content) {
        self.graphs = graphs()
    }

    @ViewBuilder
    public var body: some View {
        GeometryReader { geometry in
            VStack {
                graphs
            }
                .border(Color.red, width: 1)
                .gesture(DragGesture(minimumDistance: 0)
                    .onChanged({ value in
                        if 0...geometry.size.width ~= value.location.x {
                            viewModel.touchLocationX = value.location.x
                        } else {
                            viewModel.touchLocationX = nil
                        }
                    })
                    .onEnded({ _ in
                        viewModel.touchLocationX = nil
                    })
                )
        }
    }
}
