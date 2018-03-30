//
//  CharacterWaitingInactiveState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit

/// character is inactive, but waiting (waiting but slightly faded)
public final class CharacterWaitingInactiveState: CharacterState {
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		self.character.removeAllActions() // remove any prior actions that may affect the state
		self.character.run(InteractiveScene.fadeDown)
	}
	
	public override func willExit(to nextState: GKState) {
		super.willExit(to: nextState)
		self.character.removeAllActions() // remove any prior actions that may affect the state
		self.character.run(InteractiveScene.fadeUp)
	}
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		return stateClass is CharacterInRangeState.Type || stateClass is CharacterWaitingState.Type
	}

}
