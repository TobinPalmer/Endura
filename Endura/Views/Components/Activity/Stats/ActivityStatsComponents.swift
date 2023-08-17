//
// Created by Tobin Palmer on 8/17/23.
//

import Foundation
import SwiftUI

struct ActivityStatsVLine: View {
    var body: some View {
        HStack(spacing: 1) {
            Divider().frame(width: 1)
        }
        .frame(width: 1, height: 30)
    }
}

struct ActivityStatsDiscriptionText: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .foregroundColor(.secondary)
            .font(.system(size: 12))
            .minimumScaleFactor(0.5)
    }
}

struct ActivityStatsValueText: View {
    private let text: String

    public init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize))
            .lineLimit(1)
            .minimumScaleFactor(0.5)
    }
}

struct ActivityStatsSection<Content>: View where Content: View {
    private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack {
            content()
        }
        .frame(maxWidth: UIScreen.main.bounds.width / 2)
    }
}

struct ActivityGridSection<Content>: View where Content: View {
    @ViewBuilder private let content: () -> Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    var body: some View {
        VStack {
            HStack {
                content()
            }
            .frame(alignment: .leading)
        }
        .padding(.vertical, 5)
    }
}
