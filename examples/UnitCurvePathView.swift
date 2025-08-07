//
//  UnitCurvePathView.swift
//  examples
//
//  Created by wangqiyang on 2025/8/7.
//

import SwiftUI

struct UnitCurvePathView: View {
    private var unitCurve: UnitCurve {
        UnitCurve.bezier(
            startControlPoint: UnitPoint(x: p1.x, y: p1.y),
            endControlPoint: UnitPoint(x: p2.x, y: p2.y)
        )
    }

    private var aniamtion: Animation {
        Animation.timingCurve(unitCurve, duration: animationDuration)
    }

    @State private var p1: UnitPoint = UnitPoint(x: 1.0, y: 1.0)
    @State private var p2: UnitPoint = UnitPoint(x: 0.0, y: 0.0)
    @State private var isActive = false
    @State private var animationDuration: TimeInterval = 0.5

    @ViewBuilder
    func draggableControlPoint(
        color: Color,
        point: Binding<UnitPoint>,
        size: CGSize
    ) -> some View {
        VStack {
            Circle()
                .fill(.white)
                .stroke(color, lineWidth: 2)
                .shadow(color: color.opacity(0.4), radius: 2)
                .frame(width: 16, height: 16)
        }
        .frame(width: 100, height: 60)
        .overlay(alignment: .top) {
            let p = point.wrappedValue
            Text("(\(p.x.format()), \(p.y.format()))")
                .monospacedDigit()
                .background()
        }
        .position(
            x: point.wrappedValue.x * size.width,
            y: (1 - point.wrappedValue.y) * size.height
        )
        .gesture(
            DragGesture()
                .onChanged { value in
                    let newX = min(max(value.location.x / size.width, 0), 1)
                    let newY = min(
                        max(1 - value.location.y / size.height, -0.2),
                        1.2
                    )
                    point.wrappedValue = UnitPoint(x: newX, y: newY)
                }
        )
    }

    var body: some View {
        VStack {
            GeometryReader { geometry in
                let size = geometry.size

                ZStack {
                    Path { path in
                        path.move(to: .init(x: -50, y: size.height))
                        path.addLine(
                            to: .init(x: size.width + 50, y: size.height)
                        )
                    }
                    .stroke(.secondary.opacity(0.55), lineWidth: 2)

                    Path { path in
                        path.move(to: .init(x: 0, y: size.height + 50))
                        path.addLine(to: .init(x: 0, y: -50))
                    }
                    .stroke(.secondary.opacity(0.55), lineWidth: 2)

                    Path { path in
                        path.move(to: .init(x: size.width + 50, y: 0))
                        path.addLine(to: .init(x: -50, y: 0))
                    }
                    .stroke(.secondary.opacity(0.35), lineWidth: 2)

                    Path { path in
                        path.move(
                            to: .init(x: size.width, y: size.height + 50)
                        )
                        path.addLine(to: .init(x: size.width, y: -50))
                    }
                    .stroke(.secondary.opacity(0.35), lineWidth: 2)

                    Path { path in
                        path.move(to: .init(x: 0, y: size.height))
                        path.addLine(
                            to: CGPoint(
                                x: p1.x * size.width,
                                y: (1 - p1.y) * size.height
                            )
                        )
                    }
                    .stroke(
                        .blue.gradient,
                        style: .init(lineWidth: 2, dash: [5, 5])
                    )

                    Path { path in
                        path.move(to: .init(x: size.width, y: 0))
                        path.addLine(
                            to: .init(
                                x: p2.x * size.width,
                                y: (1 - p2.y) * size.height
                            )
                        )
                    }
                    .stroke(
                        .blue.gradient,
                        style: .init(lineWidth: 2, dash: [5, 5])
                    )

                    Text("Time")
                        .position(x: size.width, y: size.height + 20)

                    Text("Progress")
                        .rotationEffect(Angle(degrees: 90))
                        .position(x: -20, y: 0)

                    Path { path in
                        let steps = 100
                        let t0 = 0.0
                        let y0 = unitCurve.value(at: t0)
                        let startPoint = CGPoint(
                            x: t0 * size.width,
                            y: (1 - y0) * size.height
                        )

                        path.move(to: startPoint)

                        for step in 1...steps {
                            let t = Double(step) / Double(steps)
                            let y = unitCurve.value(at: t)
                            path.addLine(
                                to: CGPoint(
                                    x: t * size.width,
                                    y: (1 - y) * size.height
                                )
                            )
                        }
                    }
                    .stroke(.blue.gradient, lineWidth: 2)

                    draggableControlPoint(
                        color: .red,
                        point: $p1,
                        size: size
                    )
                    draggableControlPoint(
                        color: .green,
                        point: $p2,
                        size: size
                    )
                }
            }
            .frame(width: 200, height: 200)
        }
        .frame(width: 300, height: 300)
    }
}

extension CGFloat {
    func format(_ digits: Int = 2) -> String {
        self.formatted(
            FloatingPointFormatStyle<CGFloat>().precision(
                .fractionLength(digits)
            )
        )
    }
}

#Preview {
    UnitCurvePathView()
}
