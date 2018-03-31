//
//  PaperEncryptedState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 31/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

public final class PaperEncryptedState: PaperState {
	
	public static let moveToCryptoTime: TimeInterval = 0.8
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		guard let previous = previousState else { return }
		switch previous {
		case is PaperNormalState:
			// coming from normal, morph to crypto and play the morph sound
			self.messageNode.messageScene.morphToCrypto(duration: PaperEncryptedState.moveToCryptoTime)
			self.messageNode.run(PaperState.encryptSound)
		case is PaperErrorState:
			// coming from error, we want a shorter flash time
			self.messageNode.messageScene.morphToCrypto(duration: PaperErrorState.errorFlashTime)
		default:
			return
		}
	}
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		return stateClass is PaperErrorState.Type || stateClass is PaperNormalState.Type
	}
	
}
