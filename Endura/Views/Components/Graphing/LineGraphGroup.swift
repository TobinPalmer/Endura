//
// Created by Tobin Palmer on 7/24/23.
//

import Foundation
import SwiftUI

public class LineGraphViewModel: ObservableObject {
    @Published var touchLocationX: CGFloat? = nil {

        didSet(oldValue) {
            if (touchLocationX != oldValue) {
                print("touchLocationX", touchLocationX)
            }
        }
    }
}

public struct LineGraphGroup<Content: View>: View {
    private let graphs: Content
    @EnvironmentObject var viewModel: ActivityViewModel
//    @EnvironmentObject var viewModel: LineGraphViewModel

    public init(@ViewBuilder graphs: () -> Content) {
        self.graphs = graphs()
    }

    @ViewBuilder
    public var body: some View {
        GeometryReader { geometry in
            VStack {
                graphs
            }
                    .gesture(DragGesture(minimumDistance: 0)
                            .onChanged({ value in
                                if 0...geometry.size.width ~= value.location.x {
                                    let x = value.location.x
//                                    print("Here")
//                                    viewModel.touchLocationX = x
                                } else {
//                                    viewModel.touchLocationX = nil
                                }
                            })
                            .onEnded({ _ in
//                                viewModel.touchLocationX = nil
                            })
                    )
        }
    }
}
