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
	
	private let encryptSound = SKAction.playSoundFileNamed("encrypt.caf", waitForCompletion: false)
	private let decryptSound = SKAction.playSoundFileNamed("decrypt.caf", waitForCompletion: false)
	private let failSound = SKAction.playSoundFileNamed("fail.caf", waitForCompletion: false)
	
	/// a reference to the node that contains the scene, that we will run the sound actions on
	public unowned let messageNode:Message3DNode
	
	/// a reference to the paper scene that should be transforming
	public unowned let paperScene:Message3DScene
	
	// MARK: - Lifecycle
	
	public init(messageNode:Message3DNode, paperScene:Message3DScene) {
		self.messageNode = messageNode
		self.paperScene = paperScene
	}
	
}
