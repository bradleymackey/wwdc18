//
//  InteractiveScene.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 22/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

/// the interactive scene used to display the real scenario
/// - note: the aim of this scene is to give the user a real understanding of RSA and how it is really used
public final class InteractiveScene: RSAScene, SKPhysicsContactDelegate  {
	
	// MARK: - Properties
	
	// MARK: - Setup
	
	public override func sceneDidLoad() {
		super.sceneDidLoad()
		// setup the physics of the world
		self.setupWorldPhysics()
	}
	
	override public func setupWorldPhysics() {
		super.setupWorldPhysics()
		self.physicsWorld.contactDelegate = self
	}
	
	// MARK: - Methods
	
	override public func touchDown(atPoint point: CGPoint) {
		
	}
	
	override public func touchMoved(toPoint point: CGPoint) {
		
	}
	
	override public func touchUp(atPoint point: CGPoint) {
		
	}
	
	public func didBegin(_ contact: SKPhysicsContact) {
		// determine the contact such that the lower bitMask valued body is the `firstBody`
		var firstBody: SKPhysicsBody
		var secondBody: SKPhysicsBody
		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		} else {
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}
	}
	

}
