//
//  SCControlsView.swift
//  SCCastroControls
//
//  Created by Yichi on 4/03/2015.
//  Copyright (c) 2015 Subjective-C. All rights reserved.
//

import UIKit

protocol SCControlsViewDelegate {
	func controlsView(controlsView: SCControlsView!, didTapPlayButton playButton: UIButton!)
	func controlsView(controlsView: SCControlsView!, didTapPauseButton playButton: UIButton!)
	func controlsView(controlsView: SCControlsView!, didTapRewindButton playButton: UIButton!)
	func controlsView(controlsView: SCControlsView!, didTapFastForwardButton playButton: UIButton!)
}

class SCControlsView : UIView {
	lazy var playPauseButton:UIButton = {
		let b = UIButton.buttonWithType(.Custom) as UIButton
		b.setImage(UIImage(named: "play"), forState: .Normal)
		b.setImage(UIImage(named: "pause"), forState: .Selected)
		b.addTarget(self, action: "playPauseButtonTapped:", forControlEvents: .TouchUpInside)
		return b
	}()
	lazy var rewindButton:UIButton = {
		let b = UIButton.buttonWithType(.Custom) as UIButton
		b.setImage(UIImage(named: "rewind"), forState: .Normal)
		b.addTarget(self, action: "rewindButtonTapped:", forControlEvents: .TouchUpInside)
		return b
	}()
	lazy var fastForwardButton:UIButton = {
		let b = UIButton.buttonWithType(.Custom) as UIButton
		b.setImage(UIImage(named: "forward"), forState: .Normal)
		b.addTarget(self, action: "fastForwardButtonTapped:", forControlEvents: .TouchUpInside)
		return b
	}()
	
	lazy var elapsedTimeLabel:UILabel = {
		let l = UILabel(frame: CGRectZero)
		l.textAlignment = .Right
		l.textColor = UIColor.whiteColor()
		l.font = UIFont.systemFontOfSize(12)
		return l
	}()
	lazy var remainingTimeLabel:UILabel = {
		let l = UILabel(frame: CGRectZero)
		l.textColor = UIColor.whiteColor()
		l.font = UIFont.systemFontOfSize(12)
		return l
	}()
	
	var delegate:SCControlsViewDelegate?
	
	private lazy var leftGrabHandleView:UIImageView = {
		let v = UIImageView(image: UIImage(named: "grab_handle"))
		v.alpha = 0.2
		return v
	}()
	private lazy var rightGrabHandleView:UIImageView = {
		let v = UIImageView(image: UIImage(named: "grab_handle"))
		v.alpha = 0.2
		return v
	}()
	
	let kButtonWidth:CGFloat = 60
	let kButtonEdgeInset:CGFloat = 60
	let kGrabHandleInset:CGFloat = 10
	
	// MARK: Init
	override init(frame: CGRect) {
		super.init(frame: frame)

		addSubview(playPauseButton)
		addSubview(rewindButton)
		addSubview(fastForwardButton)
		
		addSubview(elapsedTimeLabel)
		addSubview(remainingTimeLabel)
		
		addSubview(leftGrabHandleView)
		addSubview(rightGrabHandleView)
		
	}
	
	required init(coder aDecoder: NSCoder) {
	    fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Layout
	override func layoutSubviews() {
		super.layoutSubviews()
		
		playPauseButton.sizeToFit()
		rewindButton.sizeToFit()
		fastForwardButton.sizeToFit()
		
		playPauseButton.frame = CGRect(
									x: bounds.midX - (kButtonWidth / 2.0), 
									y: 0.0, 
									width: kButtonWidth, 
									height: bounds.height
									);
		
		rewindButton.frame = CGRect(
									x: kButtonEdgeInset, 
									y: 0.0, 
									width: kButtonWidth, 
									height: bounds.height
									);
		
		fastForwardButton.frame = CGRect(
									x: bounds.width - kButtonWidth - kButtonEdgeInset, 
									y: 0.0, 
									width: kButtonWidth, 
									height: bounds.height
									);
		
		elapsedTimeLabel.frame = CGRect(
									x: rewindButton.frame.minX - elapsedTimeLabel.bounds.width, 
									y: 0.0, 
									width: elapsedTimeLabel.bounds.width, 
									height: bounds.height
									);
		
		remainingTimeLabel.frame = CGRect(
									x: fastForwardButton.frame.maxX, 
									y: 0.0, 
									width: remainingTimeLabel.bounds.width, 
									height: bounds.height
									);
		
		leftGrabHandleView.frame = CGRect(
									x: kGrabHandleInset, 
									y: bounds.midY - leftGrabHandleView.bounds.midY, 
									width: leftGrabHandleView.bounds.width, 
									height: leftGrabHandleView.bounds.height
									);
		
		rightGrabHandleView.frame = CGRect(
									x: bounds.width - rightGrabHandleView.bounds.width - kGrabHandleInset, 
									y: bounds.midY - rightGrabHandleView.bounds.midY, 
									width: rightGrabHandleView.bounds.width, 
									height: rightGrabHandleView.bounds.height
									);

	}
	
	// MARK: Public
	func updateForPlaybackItem(playbackItem: SCPlaybackItem!) {
		elapsedTimeLabel.text = playbackItem.stringForElapsedTime()
		elapsedTimeLabel.sizeToFit()
		
		remainingTimeLabel.text = playbackItem.stringForRemainingTime()
		remainingTimeLabel.sizeToFit()
	}
	
	func configureAlphaForScrubbingState() {
		
		self.playPauseButton.alpha = 0.5
		self.rewindButton.alpha = 0.5
		self.fastForwardButton.alpha = 0.5
		
		self.elapsedTimeLabel.alpha = 0.0
		self.remainingTimeLabel.alpha = 0.0
		
		self.leftGrabHandleView.alpha = 0.0
		self.rightGrabHandleView.alpha = 0.0
	}
	
	func configureAlphaForDefaultState() {
		
		self.playPauseButton.alpha = 1.0
		self.rewindButton.alpha = 1.0
		self.fastForwardButton.alpha = 1.0
		
		self.elapsedTimeLabel.alpha = 1.0
		self.remainingTimeLabel.alpha = 1.0
		
		self.leftGrabHandleView.alpha = 1.0
		self.rightGrabHandleView.alpha = 1.0
	}
	
	// MARK: Actions
	func playPauseButtonTapped(sender: UIButton!) {
		sender.selected = !sender.selected
		if sender.selected {
			delegate?.controlsView(self, didTapPlayButton: sender)
		} else {
			delegate?.controlsView(self, didTapPauseButton: sender)
		}
	}
	
	func rewindButtonTapped(sender: UIButton!) {
		delegate?.controlsView(self, didTapRewindButton: sender)
	}

	func fastForwardButtonTapped(sender: UIButton!) {
		delegate?.controlsView(self, didTapFastForwardButton: sender)
	}
}
