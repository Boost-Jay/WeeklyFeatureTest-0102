//
//  WeeklyFeatureTest0102App.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/2.
//

import SwiftUI
import SwiftData

@main
struct WeeklyFeatureTest0102App: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            FlowView(vm: FlowVM())
        }
        .modelContainer(sharedModelContainer)
    }
}
