//
//  SCPlaybackViewController.swift
//  SCCastroControls
//
//  Created by Yichi on 1/03/2015.
//  Copyright (c) 2015 Subjective-C. All rights reserved.
//

import Foundation
import UIKit

// MARK: Consts
let kViewHeight:CGFloat = 50
let kTimelineCollapsedHeight:CGFloat = 2
let kTimelineExpandedHeight:CGFloat = 22
let kKeylineHeight:CGFloat = 1

let kCollisionBoundaryOffset:CGFloat = 10

let kPushMagnitude:CGFloat = 4
let kGravityMagnitude:CGFloat = 2

class SCPlaybackViewController : UIViewController, UICollisionBehaviorDelegate, SCControlsViewDelegate {
	
	var playbackItem:SCPlaybackItem {
		set {
			_playbackItem = newValue
			
			timelineView.updateForPlaybackItem(playbackItem)
			controlsView.updateForPlaybackItem(playbackItem)
		}
		get {
			if _playbackItem == nil {
				_playbackItem = SCPlaybackItem()
			}
			return _playbackItem!
		}
	}
	
	// MARK: Private properties:
	private var _playbackItem:SCPlaybackItem?
	
	lazy var dynamicAnimator:UIDynamicAnimator = {
		return UIDynamicAnimator(referenceView: self.view)
	}()
	
	var playbackTimer:NSTimer?
	
	lazy var scrubbingBehavior:SCScrubbingBehavior = {
		return SCScrubbingBehavior(item: self.controlsView, snapToPoint: self.view.center)
	}()
	lazy var tapHintBehavior:SCTapHintBehavior = {
		return SCTapHintBehavior(items: [self.controlsView])
	}()
	
	lazy var controlsView:SCControlsView = {
		return SCControlsView(frame: self.view.bounds)
	}()
	lazy var timelineView:SCTimelineView = {
		SCTimelineView(frame: CGRect(x: 0, y: kTimelineExpandedHeight * -1.0, width: self.view.bounds.width, height: kTimelineExpandedHeight))
	}()
	
	var touchesBeganPoint = CGPointZero
	var elapsedTimeAtTouchesBegan = NSTimeInterval(0)
	
	lazy var panGestureRecognizer:UIPanGestureRecognizer = {
		return UIPanGestureRecognizer(target: self, action: "panGestureRecognized:")
	}()
	lazy var tapGestureRecognizer:UITapGestureRecognizer = {
		return UITapGestureRecognizer(target: self, action: "tapGestureRecognized:")
	}()
	
	var timelineScrubbing = false
	var commitTimelineScrubbing = false
	var shouldCommitTimelineScrubbing:Bool {
		return commitTimelineScrubbing
	}
	
	// MARK: loadView and viewDidLoad
	override func loadView() {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: kViewHeight))
		self.view = view
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		view.backgroundColor = UIColor.blackColor()
		
		controlsView.delegate = self
		view.addSubview(controlsView)
		
		collapseTimelineViewAnimated(false)
		view.addSubview(timelineView)
		
		let keylineView = UIView(frame: CGRect(x: 0, y: kKeylineHeight * -1, width: view.bounds.width, height: kKeylineHeight))
		keylineView.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.25)
		view.addSubview(keylineView)
		
		tapHintBehavior.collisionBehavior.collisionDelegate = self
		tapHintBehavior.collisionBehavior.translatesReferenceBoundsIntoBoundary = false
		
		dynamicAnimator.addBehavior(scrubbingBehavior)
		
		controlsView.addGestureRecognizer(panGestureRecognizer)
		controlsView.addGestureRecognizer(tapGestureRecognizer)
	}
	
	// MARK: Playback timer
	func timerDidFire(sender:AnyObject) {
		if timelineScrubbing == false &&
			playbackItem.elapsedTime < playbackItem.totalTime {
				playbackItem.elapsedTime += 1
				timelineView.updateForPlaybackItem(playbackItem)
				controlsView.updateForPlaybackItem(playbackItem)
		}
	}
	
	func expandTimelineViewAnimated(animated:Bool) {
		timelineScrubbing = true
		timelineView.elapsedTimeLabel.alpha = 1.0
		
		let timelineExpansionBlock = { () -> () in
			self.timelineView.transform = CGAffineTransformIdentity
		}
		
		let completionBlock = { (completed:Bool) -> Void in
			self.commitTimelineScrubbing = true
		}
		
		if animated {
			UIView.animateWithDuration(0.2, delay: 0, options: .BeginFromCurrentState, animations: timelineExpansionBlock, completion: completionBlock)
		} else {
			timelineExpansionBlock()
			completionBlock(true)
		}
	}
	
	func collapseTimelineViewAnimated(animated:Bool) {
		timelineScrubbing = false
		timelineView.elapsedTimeLabel.alpha = 0.0
		
		if shouldCommitTimelineScrubbing == false {
			playbackItem.elapsedTime = elapsedTimeAtTouchesBegan
			timelineView.updateForPlaybackItem(playbackItem)
			controlsView.updateForPlaybackItem(playbackItem)
		}
		
		let timelineCollapsingBlock = { () -> Void in
			let timelineViewScaleTransform = CGAffineTransformMakeScale(1.0, kTimelineCollapsedHeight / kTimelineExpandedHeight)
			let timelineViewTranslationTransform = CGAffineTransformMakeTranslation(0.0, kTimelineExpandedHeight / kTimelineCollapsedHeight)
			
			self.timelineView.transform = CGAffineTransformConcat(timelineViewScaleTransform, timelineViewTranslationTransform)
		}
		
		let completionBlock = { (completed:Bool) -> Void in
			self.commitTimelineScrubbing = false
		}
		
		if animated {
			UIView.animateWithDuration(0.15, delay: 0, options: .BeginFromCurrentState, animations: timelineCollapsingBlock, completion: completionBlock)
		} else {
			timelineCollapsingBlock()
			completionBlock(true)
		}
	}
	
	// MARK: UIPanGestureRecognizer
	func panGestureRecognized(panGesture:UIPanGestureRecognizer) {
		let translationInView = panGesture.translationInView(view)
		
		if panGesture.state == .Began {
			dynamicAnimator.removeBehavior(scrubbingBehavior)
			
			touchesBeganPoint = translationInView
			elapsedTimeAtTouchesBegan = playbackItem.elapsedTime
			
			expandTimelineViewAnimated(true)
			fadeOutControls()
		} else if panGesture.state == .Changed {
			let translatedCenterX = view.center.x + (translationInView.x - self.touchesBeganPoint.x)
			
			let scrubbingProgress = (translationInView.x - touchesBeganPoint.x) / view.bounds.width
			let timeAdjustment = playbackItem.totalTime * NSTimeInterval(scrubbingProgress)
			
			playbackItem.elapsedTime = elapsedTimeAtTouchesBegan + timeAdjustment
			timelineView.updateForPlaybackItem(playbackItem)
			controlsView.updateForPlaybackItem(playbackItem)
			
			controlsView.center = CGPoint(x: translatedCenterX, y: controlsView.center.y)
		} else if panGesture.state == .Ended {
			dynamicAnimator.addBehavior(scrubbingBehavior)
			collapseTimelineViewAnimated(true)
			fadeInControls()
		}
	}
	
	// MARK: View fading
	func fadeOutControls() {
		UIView.animateWithDuration(0.2, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
			self.controlsView.configureAlphaForScrubbingState()
		}, completion: nil)
	}
	
	func fadeInControls() {
		UIView.animateWithDuration(0.15, delay: 0, options: .BeginFromCurrentState, animations: { () -> Void in
			self.controlsView.configureAlphaForDefaultState()
		}, completion: nil)
	}
	
	// MARK: UITapGestureRecognizer
	func tapGestureRecognized(tapGestureRecognizer:UITapGestureRecognizer) {
		tapHintBehavior.collisionBehavior.removeAllBoundaries()
		
		dynamicAnimator.removeBehavior(scrubbingBehavior)
		dynamicAnimator.addBehavior(tapHintBehavior)
		
		let locationInView = tapGestureRecognizer.locationInView(view)
		
		if locationInView.x < view.bounds.midX {
			let leftCollisionPointTop = CGPoint(x: kCollisionBoundaryOffset * -1, y: 0)
			let leftCollisionPointBottom = CGPoint(x: kCollisionBoundaryOffset * -1, y: view.bounds.height)
			
			tapHintBehavior.collisionBehavior.addBoundaryWithIdentifier("leftCollisionPoint", fromPoint: leftCollisionPointTop, toPoint: leftCollisionPointBottom)
			tapHintBehavior.gravityBehavior.setAngle(CGFloat(M_PI), magnitude: kGravityMagnitude)
			tapHintBehavior.pushBehavior.setAngle(0, magnitude: kPushMagnitude)
		} else {
			let rightCollisionPointTop = CGPoint(x: view.bounds.width + kCollisionBoundaryOffset, y: 0)
			let rightCollisionPointBottom = CGPoint(x: view.bounds.width + kCollisionBoundaryOffset, y: view.bounds.height)
			
			tapHintBehavior.collisionBehavior.addBoundaryWithIdentifier("rightCollisionPoint", fromPoint: rightCollisionPointTop, toPoint: rightCollisionPointBottom)
			tapHintBehavior.gravityBehavior.setAngle(0, magnitude: kGravityMagnitude)
			tapHintBehavior.pushBehavior.setAngle(CGFloat(M_PI), magnitude: kPushMagnitude)
		}
		
		tapHintBehavior.pushBehavior.active = true
	}
	
	// MARK: UICollisionBehaviorDelegate
	func collisionBehavior(behavior: UICollisionBehavior, beganContactForItem item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying, atPoint p: CGPoint) {
		dynamicAnimator.addBehavior(scrubbingBehavior)
		dynamicAnimator.removeBehavior(tapHintBehavior)
	}
	
	// MARK: SCControlsViewDelegate
	func controlsView(controlsView: SCControlsView!, didTapPlayButton playButton: UIButton!) {
		playbackTimer = NSTimer(timeInterval: NSTimeInterval(1), target: self, selector: "timerDidFire:", userInfo: nil, repeats: true)
		NSRunLoop.currentRunLoop().addTimer(playbackTimer!, forMode: NSDefaultRunLoopMode)
	}
	
	func controlsView(controlsView: SCControlsView!, didTapPauseButton playButton: UIButton!) {
		playbackTimer?.invalidate()
	}
	
	func controlsView(controlsView: SCControlsView!, didTapRewindButton playButton: UIButton!) {
		playbackItem.elapsedTime = max(0, playbackItem.elapsedTime - 30)
		timelineView.updateForPlaybackItem(playbackItem)
		controlsView.updateForPlaybackItem(playbackItem)
	}
	
	func controlsView(controlsView: SCControlsView!, didTapFastForwardButton playButton: UIButton!) {
		playbackItem.elapsedTime = min(playbackItem.totalTime, playbackItem.elapsedTime + 30)
		timelineView.updateForPlaybackItem(playbackItem)
		controlsView.updateForPlaybackItem(playbackItem)
	}
}
