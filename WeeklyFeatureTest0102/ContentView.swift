
//  ContentView.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/2.
//

import SwiftUI

struct ContentView: View {
    @State private var animate = true
    var body: some View {
        VStack {
            HStack {
                VStack(spacing: 20) {
                    Text("Before")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity)
                        .background(Color.mint.gradient)
                    
                    HStack(alignment: .top) {
                        Image(systemName: "heart.fill")
                        Image(systemName: "star.fill")
                        Image(systemName: "circle.fill")
                    }
                    .font(.largeTitle)
                    
                }
                
                VStack(spacing: 20) {
                    Text("After")
                        .font(.largeTitle)
                        .frame(maxWidth: .infinity)
                        .background(Color.orange.gradient)
                    
                    HStack(alignment: .top) {
                        Image(systemName: "heart.fill")
                        Image(systemName: "star.fill")
                            .alignmentGuide(.top, computeValue: { dimension in
                                dimension[.top] - 40
                            })
                        Image(systemName: "circle.fill")
                    }
                    .font(.largeTitle)
                }
                
            }
            .padding(32)
            HStack {
                VStack {
                    Rectangle()
                        .frame(width: 150, height: 50)
                        .foregroundStyle(.orange.gradient)
                        .alignmentGuide(HorizontalAlignment.center) { dimension in
                            dimension[animate ? HorizontalAlignment.center : HorizontalAlignment.trailing]
                        }
                    
                    Rectangle()
                        .frame(width: 150, height: 50)
                        .foregroundStyle(.mint.gradient)
                        .alignmentGuide(HorizontalAlignment.center) { dimension in
                            dimension[HorizontalAlignment.center]
                        }
                    
                    Rectangle()
                        .frame(width: 150, height: 50)
                        .foregroundStyle(.orange.gradient)
                        .alignmentGuide(HorizontalAlignment.center) { dimension in
                            dimension[animate ?  HorizontalAlignment.center : HorizontalAlignment.leading]
                        }
                }
                .animation(.snappy, value: animate)
                .onTapGesture {
                    animate.toggle()
                }
            }
        }
        
    }
}

#Preview {
    ContentView()
}
