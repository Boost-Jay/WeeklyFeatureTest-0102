//
//  UnitConvertView.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/4.
//

import SwiftUI

struct UnitConvertView: View {
    // 定義一些不同單位的測量值
    let weight: Measurement<UnitMass> = Measurement(value: 150, unit: .pounds)
    let speed: Measurement<UnitSpeed> = Measurement(value: 88, unit: .milesPerHour)
    let length: Measurement<UnitLength> = Measurement(value: 100, unit: .kilometers)
    let temperature: Measurement<UnitTemperature> = Measurement(value: 75, unit: .fahrenheit)
    
    var body: some View {
        VStack(spacing: 8) {
            // 顯示不同測量值的描述
            Text(weight.description)
            Text(speed.value, format: .number)
            Text(length.unit.symbol)
            Text(temperature.description)
            
            // 顯示溫度轉換結果
            Text(temperature.converted(to: .celsius).description)
            Text(temperature.converted(to: .kelvin).description)
        }
        .padding()
        .task {
            /// 在 SwiftUI View 的異步上下文中調用 `betterSleep` 函數
            await betterSleep(Measurement(value: 3.25, unit: .milliseconds))
            await betterSleep(Measurement(value: 3.25, unit: .seconds))
            await betterSleep(Measurement(value: 3.25, unit: .minutes))
            await betterSleep(Measurement(value: 3.25, unit: .hours))
        }
    }

    /// `betterSleep` 定義一個異步函數，用於模擬睡眠延遲
    func betterSleep(_ duration: Measurement<UnitDuration>) async {
        // 將持續時間轉換為納秒，然後使用 Task.sleep
        try? await Task.sleep(nanoseconds: UInt64(duration.converted(to: .nanoseconds).value))
    }
}

#Preview {
    UnitConvertView()
}
