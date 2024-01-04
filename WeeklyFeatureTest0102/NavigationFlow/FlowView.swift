//
//  FlowView.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/4.
//


import SwiftUI

struct FlowView: View {
    
    @StateObject var vm: FlowVM

    var body: some View {
        NavigationStack(path: $vm.navigationPath) {
            VStack() {
                Phone(vm: vm.makePhoneVM())
            }
            .navigationDestination(for: Screen.self) {screen in
                switch screen {
                case .screen2(vm: let vm):
                    Verification(vm: vm)
                case .screen3(vm: let vm):
                    NameEmail(vm: vm)
                case .screen4(vm: let vm):
                    CompanyInfo(vm: vm)
                case .screen5(vm: let vm):
                    Final(vm: vm)
                }
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

#Preview() {
    FlowView(vm: FlowVM())
}
