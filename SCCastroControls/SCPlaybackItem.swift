//
//  SCPlaybackItem.swift
//  SCCastroControls
//
//  Created by Yichi on 4/03/2015.
//  Copyright (c) 2015 Subjective-C. All rights reserved.
//

import Foundation

class SCPlaybackItem : NSObject {
	var totalTime:NSTimeInterval = 0
	var elapsedTime:NSTimeInterval {
		set {
			_elapsedTime = max(0, min(totalTime, newValue))
		}
		get {
			return _elapsedTime
		}
	}
	
	private var _elapsedTime:NSTimeInterval = 0
	
	// MARK: Public methods
	func stringForElapsedTime() -> String! {
		return stringForHours(hoursComponentForTimeInterval(elapsedTime), minutes: minutesComponentForTimeInterval(elapsedTime), seconds: secondsComponentForTimeInterval(elapsedTime))
	}
	
	func stringForRemainingTime() -> String! {
		let remainingTime = totalTime - elapsedTime
		return "-" + stringForHours(hoursComponentForTimeInterval(remainingTime), minutes: minutesComponentForTimeInterval(remainingTime), seconds: secondsComponentForTimeInterval(remainingTime))
	}
	
	// MARK: Private methods
	private func stringForHours(hours: UInt, minutes: UInt, seconds: UInt) -> String! {
		var string:NSString!
		if hours > 0 {
			string = NSString(format: "%lu:%lu:%02lu", u_long(hours), u_long(minutes), CUnsignedLong(seconds) )
		} else {
			string = NSString(format: "%lu:%02lu", u_long(minutes), CUnsignedLong(seconds) )
		}
		return string
	}
	
	private func hoursComponentForTimeInterval(timeInterval: NSTimeInterval) -> UInt {
		return UInt(timeInterval) / 60 / 60
	}
	
	private func minutesComponentForTimeInterval(timeInterval: NSTimeInterval) -> UInt {
		return (UInt(timeInterval) / 60) % 60
	}
	
	private func secondsComponentForTimeInterval(timeInterval: NSTimeInterval) -> UInt {
		return UInt(timeInterval) % 60
	}
}