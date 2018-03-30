//
//  CharacterInRangeState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

public final class CharacterInRangeState: CharacterState {
	
	private lazy var aliceSound = SKAction.playSoundFileNamed("hellolady1.caf", waitForCompletion: false)
	private lazy var bobSound = SKAction.playSoundFileNamed("helloman.caf", waitForCompletion: false)
	private lazy var eveSound = SKAction.playSoundFileNamed("hellolady2.caf", waitForCompletion: false)
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		switch stateClass {
		case is CharacterSuccessState.Type, is CharacterWaitingState.Type, is CharacterFailState.Type:
			return true
		default:
			return false
		}
	}
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		// if not already faded up to max, do that
		if character.alpha != 1 {
			self.character.run(InteractiveScene.fadeUp)
		}
		// if we transition from the waiting state, play the correct sound
		if let state = previousState, state.isKind(of: CharacterWaitingState.self), let name = self.character.name {
			switch name {
			case "aliceCharacter":
				self.character.run(aliceSound)
			case "bobCharacter":
				self.character.run(bobSound)
			case "eveCharacter":
				self.character.run(eveSound)
			default:
				break
			}
		}
	}
}
