import SwiftUI

struct ShimmerModifier: ViewModifier {
    @State private var phase: CGFloat = 0

    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.black.opacity(0.06),
                            .clear,
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 2)
                    .offset(x: -geometry.size.width + (geometry.size.width * 2 * phase))
                }
                .clipped()
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerModifier())
    }
}

struct SkeletonRow: View {
    var height: CGFloat = 16
    var width: CGFloat? = nil

    var body: some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.black.opacity(0.06))
            .frame(width: width, height: height)
            .shimmer()
    }
}

// MARK: - Dashboard Skeleton

struct DashboardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            // Greeting
            SkeletonRow(height: 28, width: 200)

            // Children avatars
            HStack(spacing: AppSpacing.md) {
                ForEach(0..<3, id: \.self) { _ in
                    VStack(spacing: 4) {
                        Circle()
                            .fill(Color.black.opacity(0.06))
                            .frame(width: 56, height: 56)
                            .shimmer()
                        SkeletonRow(height: 10, width: 40)
                    }
                }
            }

            // Quick actions
            HStack(spacing: AppSpacing.md) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: AppCornerRadius.medium)
                        .fill(Color.black.opacity(0.06))
                        .frame(height: 80)
                        .shimmer()
                }
            }

            // Section header
            SkeletonRow(height: 20, width: 150)

            // Homework cards
            ForEach(0..<3, id: \.self) { _ in
                HStack(spacing: AppSpacing.md) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.06))
                        .frame(width: 4, height: 50)
                    VStack(alignment: .leading, spacing: 6) {
                        SkeletonRow(height: 14, width: 180)
                        SkeletonRow(height: 10, width: 100)
                    }
                    Spacer()
                }
                .padding(AppSpacing.md)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
            }
        }
        .padding(AppSpacing.md)
    }
}

// MARK: - Homework List Skeleton

struct HomeworkListSkeleton: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(0..<5, id: \.self) { _ in
                HStack(spacing: AppSpacing.md) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.black.opacity(0.06))
                        .frame(width: 4, height: 50)
                        .shimmer()
                    VStack(alignment: .leading, spacing: 6) {
                        SkeletonRow(height: 14, width: 200)
                        HStack(spacing: 8) {
                            SkeletonRow(height: 10, width: 60)
                            SkeletonRow(height: 10, width: 80)
                        }
                    }
                    Spacer()
                }
                .padding(.vertical, 4)
                .padding(.horizontal, AppSpacing.md)
            }
        }
    }
}

// MARK: - Deck List Skeleton

struct DeckListSkeleton: View {
    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ForEach(0..<4, id: \.self) { _ in
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    HStack {
                        VStack(alignment: .leading, spacing: 6) {
                            SkeletonRow(height: 18, width: 160)
                            SkeletonRow(height: 12, width: 100)
                        }
                        Spacer()
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        SkeletonRow(height: 6)
                        SkeletonRow(height: 10, width: 80)
                    }
                }
                .padding(AppSpacing.md)
                .background(Color.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: AppCornerRadius.medium))
            }
        }
        .padding(AppSpacing.md)
    }
}

// MARK: - Chat Skeleton

struct ChatSkeleton: View {
    var body: some View {
        VStack(spacing: AppSpacing.lg) {
            ForEach(0..<4, id: \.self) { i in
                HStack {
                    if i % 2 == 0 {
                        Spacer(minLength: 60)
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.primaryPurple.opacity(0.15))
                            .frame(height: 40)
                            .shimmer()
                    } else {
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.black.opacity(0.04))
                            .frame(height: i == 1 ? 60 : 45)
                            .shimmer()
                        Spacer(minLength: 40)
                    }
                }
            }
            Spacer()
        }
        .padding(AppSpacing.md)
    }
}
