//
//  Final.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/4.
//

import SwiftUI
import Combine

final class FinalVM: ObservableObject, Completeable, Navigable {
    let name: String

    let didComplete = PassthroughSubject<FinalVM, Never>()
    
    init(name: String?) {
        self.name = name ?? ""
    }
    
    func didTapNext() {
        //do some network calls etc
        didComplete.send(self)
    }
}

struct Final: View {
    @StateObject var vm: FinalVM

    var body: some View {
        VStack(alignment: .center) {
            Text("Welcome to the app, \(vm.name)")
            Button(action: { self.vm.didTapNext() }, label: { Text("Next") })
        }.padding()
    }
}
