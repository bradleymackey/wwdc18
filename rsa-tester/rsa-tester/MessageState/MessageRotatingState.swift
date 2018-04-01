//
//  MessageRotatingState.swift
//  wwdc-2018
//
//  Created by Bradley Mackey on 31/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

public final class MessageRotatingState: MessageState {
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		guard let state = previousState, state.isKind(of: MessageWaitingState.self) else { return }
		guard let startPoint = self.startMovingPoint else { return }
		self.message.startRotating(at: startPoint)
	}
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		// wait after rotating
		return stateClass is MessageWaitingState.Type
	}
	
}
