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
	
	
	public override func sceneDidLoad() {
		super.sceneDidLoad()
		// setup the physics of the world
		self.setupWorldPhysics()
	}
	
	private func setupWorldPhysics() {
		self.physicsWorld.contactDelegate = self
		self.physicsWorld.gravity = CGVector(dx: 0, dy: -6)
		self.physicsBody = RSAScene.worldPhysicsBody(frame: self.frame)
	}
	

}
