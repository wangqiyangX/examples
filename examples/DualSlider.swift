//
//  DualSlider.swift
//  examples
//
//  Created by wangqiyang on 2025/8/7.
//

import SwiftUI

#if os(iOS)
    struct DualSlider: View {
        @Binding var lowerValue: Double
        @Binding var upperValue: Double
        var range: ClosedRange<Double>
        var step: Double
        var onEditingChanged: (Bool) -> Void = { _ in }

        private let trackWidth: CGFloat = 338
        private let handleWidth: CGFloat = 38

        private var lowerPosition: CGFloat {
            CGFloat(
                (lowerValue - range.lowerBound)
                    / (range.upperBound - range.lowerBound)
            ) * (trackWidth - handleWidth)
        }

        private var upperPosition: CGFloat {
            CGFloat(
                (upperValue - range.lowerBound)
                    / (range.upperBound - range.lowerBound)
            ) * (trackWidth - handleWidth)
        }

        var body: some View {
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 100)
                    .fill(Color(uiColor: UIColor.systemFill))
                    .frame(width: trackWidth, height: 6)

                RoundedRectangle(cornerRadius: 100)
                    .fill(Color.blue)
                    .frame(
                        width: abs(upperPosition - lowerPosition) + handleWidth,
                        height: 6
                    )
                    .offset(x: min(lowerPosition, upperPosition))

                RoundedRectangle(cornerRadius: 100)
                    .fill(.white)
                    .frame(width: handleWidth, height: 24)
                    .shadow(color: .black.opacity(0.12), radius: 4, y: 0.5)
                    .shadow(color: .black.opacity(0.12), radius: 13, y: 6)
                    .offset(x: lowerPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                onEditingChanged(true)
                                let percent = min(
                                    max(
                                        0,
                                        value.location.x
                                            / (trackWidth - handleWidth)
                                    ),
                                    1
                                )
                                let newValue =
                                    range.lowerBound + percent
                                    * (range.upperBound - range.lowerBound)
                                let steppedValue =
                                    (newValue / step).rounded() * step
                                let minAllowedValue = range.lowerBound
                                let maxAllowedValue =
                                    upperValue
                                    - ((handleWidth / trackWidth)
                                        * (range.upperBound - range.lowerBound))
                                if steppedValue < maxAllowedValue {
                                    lowerValue = min(
                                        max(minAllowedValue, steppedValue),
                                        maxAllowedValue
                                    )
                                }
                            }
                            .onEnded { _ in
                                onEditingChanged(false)
                            }
                    )

                RoundedRectangle(cornerRadius: 100)
                    .fill(.white)
                    .frame(width: handleWidth, height: 24)
                    .shadow(color: .black.opacity(0.12), radius: 4, y: 0.5)
                    .shadow(color: .black.opacity(0.12), radius: 13, y: 6)
                    .offset(x: upperPosition)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                onEditingChanged(true)
                                let percent = min(
                                    max(
                                        0,
                                        value.location.x
                                            / (trackWidth - handleWidth)
                                    ),
                                    1
                                )
                                let newValue =
                                    range.lowerBound + percent
                                    * (range.upperBound - range.lowerBound)
                                let steppedValue =
                                    (newValue / step).rounded() * step
                                let maxAllowedValue = range.upperBound
                                let minAllowedValue =
                                    lowerValue
                                    + ((handleWidth / trackWidth)
                                        * (range.upperBound - range.lowerBound))
                                if steppedValue > minAllowedValue {
                                    upperValue = max(
                                        min(maxAllowedValue, steppedValue),
                                        minAllowedValue
                                    )
                                }
                            }
                            .onEnded { _ in
                                onEditingChanged(false)
                            }
                    )
            }
        }
    }

    #Preview {
        List {
            DualSliderDemoView()
        }
    }

    struct DualSliderDemoView: View {
        @State var lower = 0.2
        @State var upper = 0.8

        var body: some View {
            DualSlider(
                lowerValue: $lower,
                upperValue: $upper,
                range: 0...1,
                step: 0.01
            )
        }
    }
#endif
