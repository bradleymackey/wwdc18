//
//  CharacterFailState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit

public final class CharacterFailState: CharacterState {
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		switch stateClass {
		case is CharacterInRangeState.Type, is CharacterWaitingState.Type:
			return true
		default:
			return false
		}
	}
}
