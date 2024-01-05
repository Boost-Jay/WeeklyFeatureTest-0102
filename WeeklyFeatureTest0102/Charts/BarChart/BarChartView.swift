//
//  BarChartView.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/5.
//

import SwiftUI
import Charts

enum SleepType: String, CaseIterable {
    case lightSleep = "Light Sleep"
    case deepSleep = "Deep Sleep"
    case remSleep = "Rem Sleep"

    var color: Color {
        switch self {
        case .lightSleep:
            return .green
        case .deepSleep:
            return .yellow
        case .remSleep:
            return .pink
        }
    }
}

/// `SleepData` 清單將用於繪製長條圖。
/// 日期、時間和睡眠類型。
struct SleepData: Identifiable {
    let id: String = UUID().uuidString
    
    let date: String
    let hours: Int
    
    let sleepType: SleepType
}

struct BarChartView: View {

    var sleepData: [SleepData]

    var body: some View {
       
        Chart(sleepData) { item in
            // x軸顯示日期
            // y軸顯示小時
            BarMark(
                x: .value("Day of week", item.date),
                y: .value("Num of hours", item.hours),
                stacking: .standard
            )
            
            // 數據加上圓角
            .clipShape(RoundedRectangle(cornerRadius: 5))
            
            // 顯示資料數值
            .annotation(position: .overlay, content: {
                VStack {
                    Text("\(item.hours)")
                        .font(.system(size: 8, weight: .regular))
                        .foregroundStyle(.black)
                    
                    Spacer()
                }
            })
            // 添加自定義數據顏色
            .foregroundStyle(item.sleepType.color)
            // 添加標籤和顏色
            .foregroundStyle(by: .value("Sleep", item.sleepType.rawValue))
            
        }
        
        //自定義標籤位置和顯示內容
        .chartLegend(position: .top, alignment: .leading, spacing: 24, content: {
            HStack(spacing: 6) {
                ForEach(SleepType.allCases, id: \.self) { type in
                    Circle()
                        .fill(type.color)
                        .frame(width: 8, height: 8)
                    Text(type.rawValue)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(type.color)
                }
            }
        })
        
        // y軸使用數據間隔區分
        .chartYAxis() {
            AxisMarks(preset: .extended, position: .leading, values: .automatic(desiredCount: 6))
        }
        
        // y軸使用百分比來顯示區分
//        .chartYAxis {
//            AxisMarks(format: Decimal.FormatStyle.Percent.percent.scale(1), position: .leading, values: .automatic(desiredCount: 2))
//        }
        
        //y軸標籤
        .chartYAxisLabel("Hours")
        //圖表大小
        .frame(height: 300)
        //深色模式
//        .preferredColorScheme(.dark)
    }
}

#Preview(){
    BarChartView(sleepData: [
        SleepData(date: "Fri", hours: 1, sleepType: .lightSleep),
        SleepData(date: "Fri", hours: 3, sleepType: .deepSleep),
        SleepData(date: "Fri", hours: 2, sleepType: .remSleep),
        
        SleepData(date: "Sat", hours: 2, sleepType: .lightSleep),
        SleepData(date: "Sat", hours: 5, sleepType: .deepSleep),
        SleepData(date: "Sat", hours: 1, sleepType: .remSleep),
        
        SleepData(date: "Sun", hours: 1, sleepType: .lightSleep),
        SleepData(date: "Sun", hours: 4, sleepType: .deepSleep),
        SleepData(date: "Sun", hours: 3, sleepType: .remSleep),
        
        SleepData(date: "Mon", hours: 3, sleepType: .lightSleep),
        SleepData(date: "Mon", hours: 2, sleepType: .deepSleep),
        SleepData(date: "Mon", hours: 1, sleepType: .remSleep),
        
        SleepData(date: "Tue", hours: 2, sleepType: .lightSleep),
        SleepData(date: "Tue", hours: 3, sleepType: .deepSleep),
        SleepData(date: "Tue", hours: 2, sleepType: .remSleep),
        
        SleepData(date: "Wed", hours: 2, sleepType: .lightSleep),
        SleepData(date: "Wed", hours: 4, sleepType: .deepSleep),
        SleepData(date: "Wed", hours: 1, sleepType: .remSleep),
        
        SleepData(date: "Thu", hours: 1, sleepType: .lightSleep),
        SleepData(date: "Thu", hours: 2, sleepType: .deepSleep),
        SleepData(date: "Thu", hours: 3, sleepType: .remSleep),
    ]).padding()
}
