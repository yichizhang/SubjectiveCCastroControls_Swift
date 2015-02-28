//
//  SCTapHintBehavior.swift
//  SCCastroControls
//
//  Created by Yichi on 1/03/2015.
//  Copyright (c) 2015 Subjective-C. All rights reserved.
//

import Foundation
import UIKit

class SCTapHintBehavior : UIDynamicBehavior {
	var pushBehavior:UIPushBehavior!
	var gravityBehavior:UIGravityBehavior!
	var collisionBehavior:UICollisionBehavior!
	
	init(items:[AnyObject]) {
		super.init()
		
		pushBehavior = UIPushBehavior(items: items, mode:UIPushBehaviorMode.Instantaneous)
		addChildBehavior(pushBehavior)
		
		gravityBehavior = UIGravityBehavior(items: items)
		addChildBehavior(gravityBehavior)
		
		collisionBehavior = UICollisionBehavior(items: items)
		addChildBehavior(collisionBehavior)
	}
}