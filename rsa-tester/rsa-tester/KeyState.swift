//
//  GameStates.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

/// possible states that a key can be in
public class KeyState: GKState {
	
	// MARK: - Properties
	
	public let key: KeySprite
	
	// MARK: - Lifecycle
	
	required init(key: KeySprite) {
		self.key = key
	}
	
	// MARK: - Methods
	
	public func fadeKeyDown(to alpha:CGFloat, time:TimeInterval) {
		let fadeDown = SKAction.fadeAlpha(to: alpha, duration: time)
		key.run(fadeDown, withKey: "fadeDown")
	}
	
	public func fadeKeyUp(time:TimeInterval) {
		let fadeUp = SKAction.fadeIn(withDuration: time)
		key.run(fadeUp, withKey: "fadeUp")
	}
	
}
