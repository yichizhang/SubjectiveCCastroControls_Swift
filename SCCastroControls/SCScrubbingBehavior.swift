//
//  SCScrubbingBehavior.swift
//  SCCastroControls
//
//  Created by Yichi on 1/03/2015.
//  Copyright (c) 2015 Subjective-C. All rights reserved.
//

import Foundation
import UIKit

class SCScrubbingBehavior : UIDynamicBehavior {
	
	init(item: UIDynamicItem, snapToPoint point:CGPoint){
		super.init()
		
		let dynamicItemBehavior = UIDynamicItemBehavior(items: [item])
		dynamicItemBehavior.allowsRotation = false
		addChildBehavior(dynamicItemBehavior)
		
		let snapBehavior = UISnapBehavior(item: item, snapToPoint: point)
		snapBehavior.damping = 0.35
		addChildBehavior(snapBehavior)
	}
}
