//
//  PaperNormalState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 31/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

public final class PaperNormalState: PaperState {
	
	public static let moveToPaperTime: TimeInterval = 0.8
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		guard let previous = previousState else { return }
		switch previous {
		case is PaperEncryptedState:
			// coming from normal, morph to crypto and play the morph sound
			self.messageNode.messageScene.morphToPaper(duration: PaperNormalState.moveToPaperTime)
			self.messageNode.run(PaperState.encryptSound)
		case is PaperErrorState:
			// coming from error, we want a shorter flash time
			self.messageNode.messageScene.morphToPaper(duration: PaperErrorState.errorFlashTime)
		default:
			return
		}
	}
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		return stateClass is PaperErrorState.Type || stateClass is PaperEncryptedState.Type
	}
	
}
