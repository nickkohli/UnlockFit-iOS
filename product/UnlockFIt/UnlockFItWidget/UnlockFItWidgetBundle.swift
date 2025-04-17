//
//  UnlockFItWidgetBundle.swift
//  UnlockFItWidget
//
//  Created by woozy on 17/04/2025.
//

import WidgetKit
import SwiftUI

@main
struct UnlockFItWidgetBundle: WidgetBundle {
    var body: some Widget {
        UnlockFItWidget()
        UnlockFItWidgetControl()
        UnlockFItWidgetLiveActivity()
        ScreenTimeLiveActivity()
    }
}
