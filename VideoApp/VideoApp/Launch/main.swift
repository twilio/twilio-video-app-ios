//
//  main.swift
//  VideoApp
//
//  Created by Tim Rozum on 10/28/19.
//  Copyright © 2019 Twilio, Inc. All rights reserved.
//

import UIKit

// https://marcosantadev.com/fake-appdelegate-unit-testing-swift/
let isRunningTests = NSClassFromString("XCTestCase") != nil
let appDelegateClass = isRunningTests ? NSStringFromClass(TestAppDelegate.self) : NSStringFromClass(AppDelegate.self)
_ = UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, appDelegateClass)
