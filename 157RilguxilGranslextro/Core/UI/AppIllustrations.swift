import SwiftUI

struct EducationOrbitIllustration: View {
    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
            let radius = min(size.width, size.height) * 0.35

            var orbit = Path()
            orbit.addEllipse(in: CGRect(
                x: center.x - radius,
                y: center.y - radius * 0.65,
                width: radius * 2,
                height: radius * 1.3
            ))
            context.stroke(orbit, with: .color(.appAccent.opacity(0.7)), lineWidth: 2)

            var diagonal = Path()
            diagonal.move(to: CGPoint(x: center.x - radius * 0.9, y: center.y + radius * 0.5))
            diagonal.addLine(to: CGPoint(x: center.x + radius * 0.9, y: center.y - radius * 0.5))
            context.stroke(diagonal, with: .color(.appPrimary.opacity(0.7)), lineWidth: 2)

            let dots: [CGPoint] = [
                CGPoint(x: center.x - radius, y: center.y),
                CGPoint(x: center.x + radius * 0.8, y: center.y - radius * 0.2),
                CGPoint(x: center.x + radius * 0.2, y: center.y + radius * 0.55)
            ]
            for dot in dots {
                context.fill(Path(ellipseIn: CGRect(x: dot.x - 4, y: dot.y - 4, width: 8, height: 8)), with: .color(.appPrimary))
            }
        }
        .frame(width: 72, height: 72)
    }
}

struct TopicBannerIllustration: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.appSurface.opacity(0.8))
            HStack(spacing: 12) {
                ForEach(0..<3, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(index == 1 ? Color.appPrimary.opacity(0.55) : Color.appAccent.opacity(0.35))
                        .frame(width: 18 + CGFloat(index * 6), height: 30 + CGFloat(index * 8))
                }
            }
        }
        .frame(width: 86, height: 64)
    }
}
