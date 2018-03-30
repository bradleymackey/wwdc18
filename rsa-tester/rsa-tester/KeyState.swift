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
	
	// MARK: - Statics
	
	public static let pickupKeySound = SKAction.playSoundFileNamed("pickup.caf", waitForCompletion: false)
	public static let dropKeySound = SKAction.playSoundFileNamed("drop.caf", waitForCompletion: false)
	
	// MARK: - Properties
	
	public let key: KeySprite
	public let cage: CageSprite?
	
	// MARK: - Lifecycle
	
	required public init(key: KeySprite, associatedCage cage:CageSprite?) {
		self.key = key
		self.cage = cage
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
