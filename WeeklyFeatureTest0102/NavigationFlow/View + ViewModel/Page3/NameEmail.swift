//
//  NameEmail.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/4.
//

import SwiftUI
import Combine

final class NameEmailVM: ObservableObject, Navigable {
    @Published var name = ""
    @Published var personalEmail = ""
    
    let didComplete = PassthroughSubject<NameEmailVM, Never>()
    let skipRequested = PassthroughSubject<NameEmailVM, Never>()
    
    init(name: String? , personalEmail: String?) {
        self.name = name ?? ""
        self.personalEmail = name ?? ""
    }
    
    func didTapNext() {
        //do some network calls etc
        didComplete.send(self)
    }
    
    fileprivate func didTapSkip() {
        skipRequested.send(self)
    }
}

struct NameEmail: View {
    @StateObject var vm: NameEmailVM

    var body: some View {
        VStack(alignment: .center) {
            Text("3: Enter personal details")
            TextField("Name", text: $vm.name)
            TextField("Personal Email", text: $vm.personalEmail)
            Spacer()
                .frame(height: 12)
            Button(action: {
                self.vm.didTapNext()
            }, label: {
                Text("Enter Company Info")
            })
            Button(action: {
                self.vm.didTapSkip()
            }, label: {
                Text("Skip")
            })
            Spacer()
        }.padding()
    }
}
