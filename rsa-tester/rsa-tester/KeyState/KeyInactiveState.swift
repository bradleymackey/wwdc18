//
//  KeyInactiveState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit

/// key has faded out, it cannot be touched
public final class KeyInactiveState: KeyState {
	
	public var label:SKLabelNode?
	
	/// for fading items up that come into focus
	private let fadeUp:SKAction = {
		let action = SKAction.fadeAlpha(to: 1, duration: InteractiveScene.fadeTime)
		action.timingMode = .easeOut
		return action
	}()
	
	/// for fading items down that lose focus
	private let fadeDown:SKAction = {
		let action = SKAction.fadeAlpha(to: InteractiveScene.fadedDown, duration: InteractiveScene.fadeTime)
		action.timingMode = .easeOut
		return action
	}()
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		self.key.run(fadeDown)
		self.label?.run(fadeDown)
		self.key.isUserInteractionEnabled = true
	}
	
	public override func willExit(to nextState: GKState) {
		super.willExit(to: nextState)
		self.key.run(fadeUp)
		self.label?.run(fadeUp)
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
