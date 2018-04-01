//
//  MessageWaitingState.swift
//  wwdc-2018
//
//  Created by Bradley Mackey on 31/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

public final class MessageWaitingState: MessageState {
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		guard let previous = previousState else { return }
		// stop dragging or rotation, depending on the prior state
		switch previous {
		case is MessageDraggingState:
			self.message.stopMoving()
		case is MessageRotatingState:
			self.message.endRotation()
		default:
			break
		}
	}
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		// can either drag or rotate after waiting, depending on the type of box (intro or interactive)
		return stateClass is MessageDraggingState.Type || stateClass is MessageRotatingState.Type
	}
	
}
