//
//  MessageDraggingState.swift
//  wwdc-2018
//
//  Created by Bradley Mackey on 31/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

public final class MessageDraggingState: MessageState {
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		guard let state = previousState, state.isKind(of: MessageWaitingState.self) else { return }
		guard let startPoint = self.startMovingPoint else { return }
		self.message.startMoving(initialPoint: startPoint)
	}
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		// wait after dragging
		return stateClass is MessageWaitingState.Type
	}
	
}
