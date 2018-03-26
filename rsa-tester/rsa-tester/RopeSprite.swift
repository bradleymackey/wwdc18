//
//  RopeSprite.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 26/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

public final class RopeSprite: SKNode {
	
	public let length:Int
	public let attachmentPoint:CGPoint
	public let attachedObject:SKSpriteNode
	
	private var ropeParts = [SKSpriteNode]()
	
	public init(attachmentPoint:CGPoint, attachedObject:SKSpriteNode, ropeLength length:Int) {
		self.length = length
		self.attachedObject = attachedObject
		self.attachmentPoint = attachmentPoint
		super.init()
		self.setRopeLength(length: length)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setRopeLength(length:Int) {
		
		let first = SKSpriteNode(color: .black, size: CGSize(width: 5, height: 5))
		first.position = attachmentPoint
		first.physicsBody = SKPhysicsBody(circleOfRadius: first.size.width/2)
		first.physicsBody?.allowsRotation = true
		
		ropeParts.append(first)
		
		for ropeLink in 1..<length {
			let part = SKSpriteNode(color: .black, size: CGSize(width: 5, height: 5))
			part.position = CGPoint(x: first.position.x, y: first.position.y-(CGFloat(ropeLink)*part.size.height))
			part.physicsBody = SKPhysicsBody(circleOfRadius: part.size.width/2)
			part.physicsBody?.allowsRotation = true
			
			ropeParts.append(part)
		}
		
		guard let previous = ropeParts.last else { return }
		attachedObject.position = CGPoint(x: previous.position.x, y: previous.frame.maxY)
		ropeParts.append(attachedObject)
	}
	
	public func addRopeToScene() {
		
		guard let enclosingScene = self.scene else { return }
		
		for part in ropeParts {
			guard part.parent == nil else { continue }
			enclosingScene.addChild(part)
		}
		
		let joint = SKPhysicsJointPin.joint(withBodyA: enclosingScene.physicsBody!, bodyB: ropeParts[0].physicsBody!, anchor: attachmentPoint)
		joint.frictionTorque = 0.2
		enclosingScene.physicsWorld.add(joint)
		
		for jointNumber in 1..<ropeParts.count {
			let nodeA = ropeParts[jointNumber-1]
			let nodeB = ropeParts[jointNumber]
			let position = CGPoint(x: nodeA.frame.midX, y: nodeA.frame.minY)
			let otherJoint = SKPhysicsJointPin.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: position)
			otherJoint.frictionTorque = 0.2
			enclosingScene.physicsWorld.add(otherJoint)
		}
		
	}
	

}
