import SwiftUI

struct MessageBubbleView: View {
    let message: ChatMessage

    private var isUser: Bool {
        message.role == .user
    }

    var body: some View {
        HStack(alignment: .top) {
            if isUser { Spacer(minLength: 60) }

            if !isUser {
                // AI Avatar
                ZStack {
                    Circle()
                        .fill(Color.primaryPurple.opacity(0.15))
                        .frame(width: 32, height: 32)
                    Image(systemName: "brain")
                        .font(.caption)
                        .foregroundStyle(Color.primaryPurple)
                }
            }

            VStack(alignment: isUser ? .trailing : .leading, spacing: 4) {
                Text(message.content)
                    .font(.appBody)
                    .foregroundStyle(isUser ? .white : .primary)
                    .padding(12)
                    .background(
                        isUser ? Color.primaryPurple : Color.backgroundGray
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: 16)
                    )

                Text(message.createdAt, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            if !isUser { Spacer(minLength: 60) }
        }
        .padding(.horizontal, AppSpacing.md)
    }
}
