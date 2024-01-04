//
//  LineChartView.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/4.
//

import SwiftUI
import Charts

///`LineChartType` 類型在圖表上設計多條線。
/// - Parameter color: 設定線條顏色
enum LineChartType: String, CaseIterable, Plottable {
    case optimal = "Optimal"
    case outside = "Outside range"
    
    var color: Color {
        switch self {
            case .optimal: return .green
            case .outside: return .blue
        }
    }
    
}
///`LineChartData`存儲圖表數據的結構，包含日期、值和線條類型。
struct LineChartData {
    
    var id = UUID()
    var date: Date
    var value: Double
    
    var type: LineChartType
}

struct LineChartView: View {
    
    let data: [LineChartData]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Line Chart")
                .font(.system(size: 16, weight: .medium))
            
            // 建立圖表並配置其屬性
            Chart {
                // 遍歷數據點並為每個數據點創建線條標記
                ForEach(data, id: \.id) { item in
                    LineMark(
                        x: .value("Weekday", item.date),
                        y: .value("Value", item.value)
                    )
                    //使用自定義的線條顏色
//                     .foregroundStyle(item.type.color)
                    //使用漸變的線條顏色
                    .foregroundStyle(getLineGradient())
                    // 依據數據類型為線條設置顏色
                    .foregroundStyle(by: .value("Plot", item.type))
                    // 設定線條的插值方法
                    .interpolationMethod(.cardinal)
                        ///- Parameters:
                        ///  - linear (線性): 這是最基本的插值方法，它通過直線連接數據點，形成折線圖。
                        ///  - cardinal (基數樣條): 這種方法會創建一個更平滑的曲線來通過數據點。它基於一種稱為基數樣條的數學公式。
                        ///  - cardinal(tension: CGFloat) (帶緊張度的基數樣條): 這是基數樣條插值的一個變種，允許你通過調整緊張度參數來控制曲線的緊繃程度。
                        ///  - catmullRom (Catmull-Rom 樣條): 這種方法創建一個平滑的曲線，適合於形成自然看起來的過渡。它基於 Catmull-Rom 樣條算法。
                        ///  - catmullRom(alpha: CGFloat) (帶參數的 Catmull-Rom 樣條): 這是 Catmull-Rom 樣條的一個變體，允許通過 alpha 參數來調整曲線的特性。
                        ///  - monotone (單調樣條): 這種插值方法會創造一個平滑的曲線，同時確保曲線在數據點之間是單調的，這有助於保持數據的總體趨勢。
                        ///  - stepStart (階梯起始): 這種方法創建一種階梯狀的圖形，其中每個數據點位於其所在階梯的開始處。
                        ///  - stepCenter (階梯中心): 類似於 stepStart，但每個數據點位於其階梯的中心位置。
                        ///  - stepEnd (階梯結束): 這也是一種階梯狀圖形，但數據點位於階梯的結束處。
                    .lineStyle(.init(lineWidth: 3)) //調整線寬
                    
                    // 為每個數據點添加圓形符號和文字覆蓋
                    .symbol {
                        Circle()
                            .fill(item.type.color)
                            .frame(width: 12, height: 12)
                            //記錄圓點數值
                            .overlay {
                                Text("\(Int(item.value))")
                                    .frame(width: 20)
                                    .font(.system(size: 8, weight: .medium))
                                    .offset(y: -15)
                            }
                    }
                }
            }
            .chartLegend(position: .top, alignment: .leading, spacing: 24){
                HStack(spacing: 6) {
                    ForEach(LineChartType.allCases, id: \.self) { type in
                        Circle()
                            .fill(type.color)
                            .frame(width: 8, height: 8)
                        Text(type.rawValue)
                            .foregroundStyle(type.color)
                            .font(.system(size: 11, weight: .medium))
                    }
                }
            }
            // X軸顯示的月份
            .chartXAxis {
                AxisMarks(preset: .extended, values: .stride (by: .month)) { value in
                    AxisValueLabel(format: .dateTime.month())
                }
            }
            // Y軸顯示的數值位置
            .chartYAxis {
                AxisMarks(preset: .extended, position: .leading, values: .stride(by: 5))
            }
            //深色模式
            //.preferredColorScheme(.dark)
        }
        .frame(height: 360)
    }
    
    ///`getLineGradient`產生漸變色彩
    func getLineGradient() -> LinearGradient {
        return LinearGradient(
            stops: [
                .init(color: .red, location: 0),
                .init(color: .green, location: 0.1),
                .init(color: .yellow, location: 0.3),
                .init(color: .blue, location: 0.5),
                .init(color: .orange, location: 0.8),
                .init(color: .black, location: 1),
            ],
            startPoint: .leading,
            endPoint: .bottomTrailing
        )
    }
}

// 生成測試用的圖表數據
var chartData : [LineChartData] = {
    let sampleDate = Date().startOfDay.adding(.month, value: -10)!
    var temp = [LineChartData]()
    
    // Line 1
    for i in 0..<8 {
        let value = Double.random(in: 5...20)
        temp.append(
            LineChartData(
                date: sampleDate.adding(.month, value: i)!,
                value: value,
                type: .outside
            )
        )
    }
    
    // Line 2
    for i in 0..<8 {
        let value = Double.random(in: 5...20)
        temp.append(
            LineChartData(
                date: sampleDate.adding(.month, value: i)!,
                value: value,
                type: .optimal
            )
        )
    }
    
    return temp
}()


#Preview {
    VStack {
        Spacer()
        LineChartView(data: chartData)
            .padding()
        Spacer()
    }
}

//
/// - Parameters:
///  - adding: 用於將組件新增至日期
///  - startOfDay: 用於取得一天的開始時間
extension Date {
    func adding (_ component: Calendar.Component, value: Int, using calendar: Calendar = .current) -> Date? {
        return calendar.date(byAdding: component, value: value, to: self)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
