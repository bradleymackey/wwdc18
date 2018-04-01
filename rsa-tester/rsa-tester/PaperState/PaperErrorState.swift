//
//  PaperErrorState.swift
//  wwdc-2018
//
//  Created by Bradley Mackey on 31/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

/// the question mark state of the 3D message/ paper box 
public final class PaperErrorState: PaperState {
	
	public static let errorFlashTime:TimeInterval = 0.4
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		guard let previous = previousState else { return }
		// play the error sound
		self.messageNode.run(PaperState.failSound)
		// morph to the question mark state
		self.messageNode.messageScene.morphToQuestionMark(duration: PaperErrorState.errorFlashTime)
		let shortWait = SKAction.wait(forDuration: PaperErrorState.errorFlashTime)
		guard let otherAction = morphAction(forState: previous) else { return }
		let sequence = SKAction.sequence([shortWait,otherAction])
		self.messageNode.run(sequence)
	}
	
	private func morphAction(forState state:GKState) -> SKAction? {
		switch state {
		case is PaperNormalState:
			return SKAction.customAction(withDuration: 0) { _, _ in
				self.messageNode.sceneStateMachine.enter(PaperNormalState.self)
			}
		case is PaperEncryptedState:
			return SKAction.customAction(withDuration: 0) { _, _ in
				self.messageNode.sceneStateMachine.enter(PaperEncryptedState.self)
			}
		default:
			return nil
		}
	}
	
	
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		return stateClass is PaperEncryptedState.Type || stateClass is PaperNormalState.Type
	}
	
}
