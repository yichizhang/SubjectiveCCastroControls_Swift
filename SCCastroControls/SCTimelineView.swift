//
//  SCTimelineView.swift
//  SCCastroControls
//
//  Created by Yichi on 2/03/2015.
//  Copyright (c) 2015 Subjective-C. All rights reserved.
//

import UIKit

class SCTimelineView: UIView {
	lazy var progressView:UIView = {
		let v = UIView(frame: CGRectZero)
		v.backgroundColor = UIColor.whiteColor()
		return v
	}()
	lazy var elapsedTimeLabel:UILabel = {
		let l = UILabel(frame: CGRectZero)
		l.textAlignment = .Center
		l.font = UIFont.boldSystemFontOfSize(15)
		return l
	}()
	
	let kLabelWidthPadding:CGFloat = 10
	
	// MARK: Init Method
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		clipsToBounds = true
		backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.5)
		
		addSubview(progressView)
		addSubview(elapsedTimeLabel)
	}

	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Public Methods
	func updateForPlaybackItem(playbackItem:SCPlaybackItem) {
		updateProgressViewForPlaybackItem(playbackItem)
		updateElapsedTimeLabelForPlaybackItem(playbackItem)
	}
	
	// MARK: Private Methods
	func updateProgressViewForPlaybackItem(playbackItem:SCPlaybackItem) {
		if playbackItem.totalTime > 0 {
			let progress = CGFloat( playbackItem.elapsedTime / playbackItem.totalTime )
			progressView.frame = CGRect(x: 0, y: 0, width: bounds.width * progress, height: bounds.height)
		}
	}
	
	func updateElapsedTimeLabelForPlaybackItem(playbackItem:SCPlaybackItem) {
		elapsedTimeLabel.text = playbackItem.stringForElapsedTime()
		
		elapsedTimeLabel.sizeToFit()
		let labelSize = elapsedTimeLabel.bounds.size
		elapsedTimeLabel.frame = CGRect(x: elapsedTimeLabel.frame.minX, y: elapsedTimeLabel.frame.minY, width: labelSize.width + kLabelWidthPadding, height: bounds.height)
		
		if elapsedTimeLabel.bounds.width > progressView.bounds.width {
			configureElapsedLabelOriginForPendingSegment()
		} else {
			configureElapsedLabelOriginForElapsedSegment()
		}
		
	}
	
	func configureElapsedLabelOriginForElapsedSegment() {
		elapsedTimeLabel.textColor = UIColor.blackColor()
		var f = elapsedTimeLabel.frame
		f.origin.x = progressView.frame.maxX - elapsedTimeLabel.bounds.width
		elapsedTimeLabel.frame = f
	}
	
	func configureElapsedLabelOriginForPendingSegment() {
		elapsedTimeLabel.textColor = UIColor.whiteColor()
		var f = elapsedTimeLabel.frame
		f.origin.x = progressView.frame.maxX
		elapsedTimeLabel.frame = f
	}
}
