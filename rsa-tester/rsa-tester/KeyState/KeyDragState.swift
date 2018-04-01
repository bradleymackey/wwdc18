//
//  DraggingKey.swift
//  wwdc-2018
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

public final class KeyDragState: KeyState {
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		// if we were previously waiting, play the key pickup sound
		guard let state = previousState, state.isKind(of: KeyWaitState.self) else { return }
		self.key.removeAllActions()
		guard let movingPoint = self.startMovingPoint else { return }
		self.key.startMoving(initialPoint: movingPoint)
		self.key.run(KeyState.pickupKeySound, withKey: "pickupKeySound")
	}
	
	public override func willExit(to nextState: GKState) {
		super.willExit(to: nextState)
	}
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		// we can only wait after we drag
		switch stateClass {
		case is KeyWaitState.Type:
			return true
		default:
			return false
		}
	}
	
}
