//
//  Verification.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/4.
//

import SwiftUI
import Combine


final class VerificationVM: ObservableObject, Completeable, Navigable {
    @Published var verification = ""
    var phoneNumber: String

    let didComplete = PassthroughSubject<VerificationVM, Never>()
    
    init(phoneNumber: String?) {
        self.phoneNumber = phoneNumber ?? ""
    }
    
    func didTapNext() {
        //do some network calls etc
        didComplete.send(self)
    }
}


struct Verification: View {
    @StateObject var vm: VerificationVM

    var body: some View {
        VStack(alignment: .center) {
            Text("2: Verification sent to \(vm.phoneNumber)")
            TextField("Verfication Number", text: $vm.verification)
            Button(action: {
                self.vm.didTapNext()
            }, label: {
                Text("Next")
            })
        }.padding()
    }
}

#Preview() {
    Verification(vm: VerificationVM(phoneNumber: nil))
}
