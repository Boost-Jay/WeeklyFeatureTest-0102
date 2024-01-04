//
//  FlowVM.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/4.
//

import Foundation
import Combine
import SwiftUI

protocol Completeable {
    var didComplete: PassthroughSubject<Self, Never> { get }
}

protocol Navigable: AnyObject, Identifiable, Hashable {}

extension Navigable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum Screen: Hashable {
    case screen2(vm: VerificationVM)
    case screen3(vm: NameEmailVM)
    case screen4(vm: WorkInfoVM)
    case screen5(vm: FinalVM)
}

class FlowVM: ObservableObject {
    
    // Note the final model is manually "bound" to the view models here.
    // Automatic binding would be possible with combine or even a single VM.
    // However this may not scale well
    // and the views become dependant on something that is external to the view.
    private let model: FlowModel
    var subscription = Set<AnyCancellable>()
    
    @Published var navigationPath: [Screen] = []
    
    init() {
        self.model = FlowModel()
    }

    func makePhoneVM() -> PhoneVM {
        let vm = PhoneVM(phoneNumber: model.phoneNumber)
        vm.didComplete
            .sink(receiveValue: didComplete1)
            .store(in: &subscription)
        return vm
    }
    
    func makeVerificationVM() -> VerificationVM {
        let vm = VerificationVM(phoneNumber: model.phoneNumber)
        vm.didComplete
            .sink(receiveValue: didComplete2)
            .store(in: &subscription)
        return vm
    }
    
    func makeNameEmailVM() -> NameEmailVM {
        let vm = NameEmailVM(
            name: model.name,
            personalEmail: model.workEmail
        )
        vm.didComplete
            .sink(receiveValue: didComplete3)
            .store(in: &subscription)
        vm.skipRequested
            .sink(receiveValue: skipRequested)
            .store(in: &subscription)
        return vm
    }
    
    func makeWorkInfoVM() -> WorkInfoVM {
        let vm = WorkInfoVM(workEmail: model.workEmail)
        vm.didComplete
            .sink(receiveValue: didComplete4)
            .store(in: &subscription)
        vm.goToRootRequested
            .sink(receiveValue: goToRootRequested)
            .store(in: &subscription)
        vm.goTo2Requested
            .sink(receiveValue: goTo2Requested)
            .store(in: &subscription)
        vm.goTo3Requested
            .sink(receiveValue: goTo3Requested)
            .store(in: &subscription)
        vm.testActionRequested
            .sink(receiveValue: testAction)
            .store(in: &subscription)
        return vm
    }
    
    func makeFinalVM() -> FinalVM {
        let vm = FinalVM(name: model.name)
        vm.didComplete
            .sink(receiveValue: didComplete5)
            .store(in: &subscription)
        return vm
    }
    
    func didComplete1(vm: PhoneVM) {
        // Additional logic inc. updating model
        model.phoneNumber = vm.phoneNumber
        navigationPath.append(.screen2(vm: makeVerificationVM()))
    }
    
    func didComplete2(vm: VerificationVM) {
        // Additional logic
        navigationPath.append(.screen3(vm: makeNameEmailVM()))
    }
    
    func didComplete3(vm: NameEmailVM) {
        // Additional logic inc. updating model
        updateModel(vm: vm)
        navigationPath.append(.screen4(vm: makeWorkInfoVM()))
    }
    
    func skipRequested(vm: NameEmailVM) {
        // Additional logic inc. updating model
        updateModel(vm: vm)
        navigationPath.append(.screen5(vm: makeFinalVM()))
    }
    
    func updateModel(vm: NameEmailVM) {
        model.name = vm.name
        model.personalEmail = vm.personalEmail
    }
    
    func didComplete4(vm: WorkInfoVM) {
        // Additional logic inc. updating model
        model.workEmail = vm.workEmail
        navigationPath.append(.screen5(vm: makeFinalVM()))
    }
    
    func goToRootRequested(vm: WorkInfoVM) {
        navigationPath = []
    }

    func goTo2Requested(vm: WorkInfoVM) {
        // Could also do navigationPath.removeLast(2), but this is is less stable
        navigationPath = [.screen2(vm: makeVerificationVM())]
    }

    func goTo3Requested(vm: WorkInfoVM) {
        navigationPath.removeLast()
    }
    
    func testAction(vm: WorkInfoVM) {
        // This doesn't even make sense but it's possible
        // Will feel like backwards navigation but you end up on the same with the first removed.
        navigationPath.removeFirst()
    }
    
    func didComplete5(vm: FinalVM) {
        // Switch out navigation.  Model now complete.
        print("Complete")
        print(model)
    }
}
