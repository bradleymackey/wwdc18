//
//  KeyCagedState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit

/// - important: being inactive and being caged are mutually exclusive. The key must be one or the other, it cannot be both.
public final class KeyCagedState: KeyState {
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
	}
	
	public override func willExit(to nextState: GKState) {
		super.willExit(to: nextState)
	}
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		// we can only wait after we are caged
		switch stateClass {
		case is KeyWaitState.Type:
			return true
		default:
			return false
		}
	}
	
	
}
