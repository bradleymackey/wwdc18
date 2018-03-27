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
		
		
		let first = SKSpriteNode(imageNamed: "ring.png")
		first.size = CGSize(width: 5, height: 5)
		first.position = attachmentPoint
		first.physicsBody = SKPhysicsBody(circleOfRadius: first.size.height)
		first.physicsBody?.allowsRotation = true
		first.physicsBody?.affectedByGravity = true
		first.physicsBody?.isDynamic = true
		
		ropeParts.append(first)
		
		for ropeLink in 1..<length {
			let part = SKSpriteNode(imageNamed: "ring.png")
			part.size = CGSize(width: 5, height: 5)
			part.position = CGPoint(x: first.position.x, y: first.position.y-(CGFloat(ropeLink)*(part.size.height)))
			part.physicsBody = SKPhysicsBody(circleOfRadius: part.size.height)
			part.physicsBody?.allowsRotation = true
			part.physicsBody?.affectedByGravity = true
			part.physicsBody?.isDynamic = true
			
			ropeParts.append(part)
		}
		
		guard let previous = ropeParts.last else { return }
		attachedObject.position = CGPoint(x: previous.position.x, y: previous.frame.maxY)
		ropeParts.append(attachedObject)
	}
	
	public func addRopeElementsToScene() {
		
		guard let enclosingScene = self.scene else { return }
		
		for part in ropeParts {
			// only add them to the scene if they are not already in it
			guard part.parent == nil else { continue }
			enclosingScene.addChild(part)
		}
		
		let joint = SKPhysicsJointPin.joint(withBodyA: enclosingScene.physicsBody!, bodyB: ropeParts[0].physicsBody!, anchor: attachmentPoint)
		enclosingScene.physicsWorld.add(joint)
		
		for jointNumber in 1..<ropeParts.count {
			let nodeA = ropeParts[jointNumber-1]
			let nodeB = ropeParts[jointNumber]
			let anchorPoint = CGPoint(x: nodeB.frame.midX, y: nodeB.frame.minY)
			let otherJoint = SKPhysicsJointPin.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: anchorPoint)
			enclosingScene.physicsWorld.add(otherJoint)
		}
		
	}
	

}
