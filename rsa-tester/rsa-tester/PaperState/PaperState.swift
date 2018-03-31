//
//  PaperState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 31/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit
import SpriteKit

/// manages the the state of the current appearance of the 3D paper object
public class PaperState: GKState {
	
	// MARK: - Properties
	
	public static let encryptSound = SKAction.playSoundFileNamed("encrypt.caf", waitForCompletion: false)
	public static let decryptSound = SKAction.playSoundFileNamed("decrypt.caf", waitForCompletion: false)
	public static let failSound = SKAction.playSoundFileNamed("fail.caf", waitForCompletion: false)
	
	/// a reference to the node that contains the scene, that we will run the sound actions on and get access to the scene inside, to manage the states
	public unowned let messageNode:Message3DNode
	
	// MARK: - Lifecycle
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		print("entered state",self.debugDescription)
	}
	
	public init(messageNode:Message3DNode) {
		self.messageNode = messageNode
	}
	
}
