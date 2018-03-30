//
//  CharacterWaitingState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

public final class CharacterWaitingState: CharacterState {

	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		return stateClass is CharacterInRangeState.Type || stateClass is CharacterWaitingInactiveState.Type
	}
	
}






