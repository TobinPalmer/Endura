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
    private let block: Bool

    public init(_ text: String, block: Bool = false) {
        self.text = text
        self.block = block
    }

    var body: some View {
        if block {
            Text(text)
                .font(Font.custom("FlowBlock-Regular", size: 12, relativeTo: .title))
                .foregroundColor(Color("Text"))
                .minimumScaleFactor(0.5)
        } else {
            Text(text)
                .foregroundColor(Color("TextMuted"))
                .font(.system(size: 12))
                .minimumScaleFactor(0.5)
        }
    }
}

struct ActivityStatsValueText: View {
    private let text: String
    private let block: Bool

    public init(_ text: String, block: Bool = false) {
        self.text = text
        self.block = block
    }

    var body: some View {
        if block {
            Text(text)
                .font(Font.custom(
                    "FlowBlock-Regular",
                    size: UIFont.preferredFont(forTextStyle: .body).pointSize,
                    relativeTo: .title
                ))
                .foregroundColor(Color("Text"))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        } else {
            Text(text)
                .font(.system(size: UIFont.preferredFont(forTextStyle: .body).pointSize))
                .foregroundColor(Color("Text"))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
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
