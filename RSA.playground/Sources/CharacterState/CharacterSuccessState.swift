//
//  CharacterSuccessState.swift
//  wwdc-2018
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

public final class CharacterSuccessState: CharacterState {
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		switch stateClass {
		case is CharacterInRangeState.Type, is CharacterWaitingState.Type, is CharacterWaitingInactiveState.Type:
			return true
		default:
			return false
		}
	}
}
