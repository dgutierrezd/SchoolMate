import SwiftUI

struct SplashScreenView: View {
    @State private var iconScale: CGFloat = 0.5
    @State private var iconOpacity: Double = 0
    @State private var titleOffset: CGFloat = 30
    @State private var titleOpacity: Double = 0
    @State private var taglineOpacity: Double = 0
    @State private var shimmerPhase: CGFloat = 0
    @State private var ringScale: CGFloat = 0.8
    @State private var ringOpacity: Double = 0

    var body: some View {
        ZStack {
            // Warm background gradient
            LinearGradient(
                colors: [
                    Color(hex: "#4A6FA5"),
                    Color(hex: "#2C3E50"),
                    Color(hex: "#34495E"),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            // Floating particles
            FloatingParticles()

            VStack(spacing: 24) {
                Spacer()

                // App Icon
                ZStack {
                    // Outer glow ring
                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [Color.accentOrange, Color.accentGreen, Color.accentOrange],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 3
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(ringScale)
                        .opacity(ringOpacity)

                    // Icon background
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "#4A6FA5"), Color(hex: "#2C3E50")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .shadow(color: Color(hex: "#4A6FA5").opacity(0.5), radius: 30, x: 0, y: 10)

                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 54, weight: .thin))
                        .foregroundStyle(.white)
                }
                .scaleEffect(iconScale)
                .opacity(iconOpacity)

                // App name
                VStack(spacing: 8) {
                    Text("SchoolMate")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    +
                    Text(" AI")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.accentOrange)
                }
                .offset(y: titleOffset)
                .opacity(titleOpacity)

                Text("Smart learning for every child")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
                    .opacity(taglineOpacity)

                Spacer()

                // Loading indicator
                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.accentOrange)
                            .frame(width: 8, height: 8)
                            .scaleEffect(shimmerPhase == CGFloat(index) ? 1.3 : 0.7)
                            .opacity(shimmerPhase == CGFloat(index) ? 1 : 0.4)
                    }
                }
                .padding(.bottom, 60)
                .opacity(taglineOpacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6).delay(0.2)) {
                iconScale = 1.0
                iconOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.4)) {
                ringScale = 1.0
                ringOpacity = 0.6
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.5)) {
                titleOffset = 0
                titleOpacity = 1.0
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.8)) {
                taglineOpacity = 1.0
            }
            Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { timer in
                withAnimation(.easeInOut(duration: 0.3)) {
                    shimmerPhase = shimmerPhase >= 2 ? 0 : shimmerPhase + 1
                }
            }
        }
    }
}

// MARK: - Floating Particles

struct FloatingParticles: View {
    @State private var particles: [Particle] = (0..<15).map { _ in Particle() }

    var body: some View {
        GeometryReader { geometry in
            ForEach(particles.indices, id: \.self) { index in
                Circle()
                    .fill(particles[index].color)
                    .frame(width: particles[index].size, height: particles[index].size)
                    .position(particles[index].position(in: geometry.size))
                    .opacity(particles[index].opacity)
                    .blur(radius: 1)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: particles[index].duration)
                            .repeatForever(autoreverses: true)
                        ) {
                            particles[index].animate()
                        }
                    }
            }
        }
    }
}

struct Particle {
    var xRatio: CGFloat = .random(in: 0...1)
    var yRatio: CGFloat = .random(in: 0...1)
    var size: CGFloat = .random(in: 3...8)
    var opacity: Double = .random(in: 0.1...0.3)
    var duration: Double = .random(in: 3...6)
    var yOffset: CGFloat = 0
    var color: Color = [Color(hex: "#F5A623"), Color(hex: "#6BBF6A"), Color.white].randomElement()!

    func position(in size: CGSize) -> CGPoint {
        CGPoint(
            x: xRatio * size.width,
            y: yRatio * size.height + yOffset
        )
    }

    mutating func animate() {
        yOffset = .random(in: -30...30)
        opacity = .random(in: 0.1...0.4)
    }
}
