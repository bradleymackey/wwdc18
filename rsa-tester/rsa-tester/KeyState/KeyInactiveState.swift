//
//  KeyInactiveState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

/// key has faded out, it cannot be touched
public final class KeyInactiveState: KeyState {
	
	/// the label that is associated with this key
	public var label:SKLabelNode?
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		self.key.run(InteractiveScene.fadeDown)
		self.label?.run(InteractiveScene.fadeDown)
		self.key.isUserInteractionEnabled = true
	}
	
	public override func willExit(to nextState: GKState) {
		super.willExit(to: nextState)
		self.key.run(InteractiveScene.fadeUp)
		self.label?.run(InteractiveScene.fadeUp)
		self.key.isUserInteractionEnabled = false
	}
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		// we can only wait after being inactive
		switch stateClass {
		case is KeyWaitState.Type:
			return true
		default:
			return false
		}
	}
	
}
