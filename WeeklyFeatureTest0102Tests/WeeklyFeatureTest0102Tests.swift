//
//  WeeklyFeatureTest0102Tests.swift
//  WeeklyFeatureTest0102Tests
//
//  Created by imac-2627 on 2024/1/4.
//

import XCTest
@testable import NavigationFlow

class WeeklyFeatureTest0102Tests: XCTestCase {
    
    func test_doesNotNavigate_whenTapNextAndPhoneNumberValid() throws {
        let sut = FlowVM()
        XCTAssertEqual(sut.navigationPath.count, 0)
        let screen1VM = sut.makeScreen1PhoneVM()
        screen1VM.didTapNext()
        XCTAssertEqual(sut.navigationPath.count, 0)
    }

    func test_navigates_whenTapNextAndPhoneNumberValid() throws {
        let sut = FlowVM()
        XCTAssertEqual(sut.navigationPath.count, 0)
        let screen1VM = sut.makeScreen1PhoneVM()
        screen1VM.phoneNumber = "5555555555"
        screen1VM.didTapNext()
        XCTAssertEqual(sut.navigationPath.count, 1)
    }
}
