//
//  UnitConvert.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/4.
//

import Foundation
@MainActor
let temperature: Measurement<UnitTemperature> = Measurement(value: 75, unit: .fahrenheit)

let tempInCelcius = temperature.converted(to: .celsius)
let tempInKelvin = temperature.converted(to: .kelvin)

func betterSleep(_ duration: Measurement<UnitDuration>) async {
    try? await Task.sleep(nanoseconds: UInt64(duration.converted(to: .nanoseconds).value))
}

// we could call our function like this,
// passing in any kind of duration measurement as the parameter
//await betterSleep(Measurement(value: 3.25, unit: .milliseconds))
//await betterSleep(Measurement(value: 3.25, unit: .seconds))
//await betterSleep(Measurement(value: 3.25, unit: .minutes))
//await betterSleep(Measurement(value: 3.25, unit: .hours))
