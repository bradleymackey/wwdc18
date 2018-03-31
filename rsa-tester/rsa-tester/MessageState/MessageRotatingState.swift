//
//  MessageRotatingState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 31/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

public final class MessageRotatingState: MessageState {
	
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		// wait after rotating
		return stateClass is MessageWaitingState.Type
	}
	
}
