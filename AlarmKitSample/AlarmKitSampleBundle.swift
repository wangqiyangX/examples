//
//  AlarmKitSampleBundle.swift
//  AlarmKitSample
//
//  Created by wangqiyang on 2025/8/10.
//

import WidgetKit
import SwiftUI

@main
struct AlarmKitSampleBundle: WidgetBundle {
    var body: some Widget {
        AlarmKitSample()
        AlarmKitSampleControl()
        AlarmKitSampleLiveActivity()
    }
}
