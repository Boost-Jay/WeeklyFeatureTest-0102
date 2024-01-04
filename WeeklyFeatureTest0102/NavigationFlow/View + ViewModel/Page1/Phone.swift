//
//  Phone.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/4.
//

import SwiftUI
import Combine

final class PhoneVM: ObservableObject, Completeable {
    @Published var phoneNumber = ""
    
    // would be more complex
    var isValid: Bool {
        !phoneNumber.isEmpty
    }
    
    let didComplete = PassthroughSubject<PhoneVM, Never>()

    init(phoneNumber: String?) {
        self.phoneNumber = phoneNumber ?? ""
    }
    
    func didTapNext() {
        //do some network calls etc
        guard isValid else {
            return
        }
        
        didComplete.send(self)
    }
}

struct Phone: View {
    @StateObject var vm: PhoneVM

    var body: some View {
        VStack(alignment: .center) {
            Text("1: We need your phone number for verification")
            TextField("Phone Number", text: $vm.phoneNumber)
            Button(action: {
                self.vm.didTapNext()
            }, label: { Text("Next") })
            .disabled(!vm.isValid)
        }.padding()
    }
}

#Preview() {
    Phone(vm: PhoneVM(phoneNumber: nil))
}
