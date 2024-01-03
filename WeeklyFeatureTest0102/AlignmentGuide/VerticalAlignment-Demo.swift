//
//  VerticalAlignment-Demo.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/2.
//

import SwiftUI


struct VerticalAlignment_Demo: View {
    @State private var selectedIndex = 0
    var courses = ["SwiftUI", "Machine Learning", "iOS", "NLP"]
    var body: some View {
        VStack {
            Text("DevTechie Courses")
                .font(.largeTitle)
            HStack(alignment: .customAlignment) {
                Image(systemName: "arrow.forward")
                
                VStack(alignment: .leading) {
                    ForEach(courses.indices, id: \.self) { idx in
                        if idx == selectedIndex {
                            Text(courses[idx])
                                .alignmentGuide(.customAlignment, computeValue: { dimension in
                                    dimension[VerticalAlignment.center] - 10        //加上偏移效果
                                })
                        } else {
                            Text(courses[idx])
                                .onTapGesture {
                                    withAnimation {
                                        selectedIndex = idx
                                    }
                                }//當點擊非選中課程時，會觸發這個手勢識別器，並將selectedIndex更新為當前點擊的課程索引。
                        }
                    }
                }
                
            }
            .font(.title)
        }
    }
}

extension VerticalAlignment {
    private enum CustomAlignment: AlignmentID {
        static func defaultValue(in context: ViewDimensions) -> CGFloat {
            return context[.bottom]
        }
    }
    
    static let customAlignment = VerticalAlignment(CustomAlignment.self)//自定義的對齊方式的默認值是基於視圖維度的底部
}

#Preview {
    VerticalAlignment_Demo()
}
