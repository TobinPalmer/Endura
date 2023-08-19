//
//  ActivityViewModel.swift created on 7/30/23.
//

import Foundation

public final class ActivityViewModel: ObservableObject {
    @Published var analysisPosition: Date? = nil
    @Published var analysisValue: Double? = nil
}
