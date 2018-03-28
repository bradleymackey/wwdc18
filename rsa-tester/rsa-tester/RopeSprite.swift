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
	
	public let attachmentPoint:CGPoint
	public let attachedElement:SKSpriteNode
	
	private var ropeParts = [SKSpriteNode]()
	
	/// the last element of the rope, so we know where to direct the rest of the rope
	public var lastRopeElement:SKNode? {
		return ropeParts.last
	}
	
	public init(attachmentPoint:CGPoint, attachedElement:SKSpriteNode, length:Int) {
		self.attachmentPoint = attachmentPoint
		self.attachedElement = attachedElement
		super.init()
		self.setRopeLength(length: length)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setRopeLength(length:Int) {
		
		
		let first = SKSpriteNode(imageNamed: "circle.png")
		first.size = CGSize(width: 5, height: 5)
		first.position = attachmentPoint
		first.physicsBody = SKPhysicsBody(circleOfRadius: first.size.height)
		first.physicsBody?.categoryBitMask = PhysicsCategory.chainLink
		first.physicsBody?.collisionBitMask = PhysicsCategory.boundry | PhysicsCategory.keys
		first.physicsBody?.contactTestBitMask = PhysicsCategory.none
		first.physicsBody?.allowsRotation = true
		first.physicsBody?.isDynamic = true
		
		ropeParts.append(first)
		
		for ropeLink in 1..<length {
			let part = SKSpriteNode(imageNamed: "circle.png")
			part.size = CGSize(width: 5, height: 5)
			part.position = CGPoint(x: first.position.x, y: first.position.y-(CGFloat(ropeLink)*(part.size.width)))
			part.physicsBody = SKPhysicsBody(circleOfRadius: part.size.height)
			part.physicsBody?.categoryBitMask = PhysicsCategory.chainLink
			part.physicsBody?.collisionBitMask = PhysicsCategory.boundry | PhysicsCategory.keys
			part.physicsBody?.contactTestBitMask = PhysicsCategory.none
			part.physicsBody?.allowsRotation = true
			part.physicsBody?.isDynamic = true
			
			ropeParts.append(part)
			
			
		}
		
		guard let previous = ropeParts.last else { return }
		attachedElement.position = CGPoint(x: previous.position.x, y: previous.frame.minY)
		ropeParts.append(attachedElement)
	}
	
	public func addRopeElementsToScene() {

		guard let enclosingScene = self.scene else { return }
		
		for item in ropeParts {
			guard item.parent == nil else { continue }
			enclosingScene.addChild(item)
		}
		
		let joint = SKPhysicsJointPin.joint(withBodyA: enclosingScene.physicsBody!, bodyB: ropeParts[0].physicsBody!, anchor: attachmentPoint)
		enclosingScene.physicsWorld.add(joint)
		
		for jointNumber in 1..<(ropeParts.count) {
			var subtract:CGFloat = 0
			if jointNumber ==  ropeParts.count - 1 {
				// on the last one, subtract 25 so the cage touches the chain
				subtract = 25
			}
			let nodeA = ropeParts[jointNumber-1]
			let nodeB = ropeParts[jointNumber]
			let anchorPoint = CGPoint(x: nodeB.frame.midX, y: nodeB.frame.maxY-subtract)
			let otherJoint = SKPhysicsJointPin.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: anchorPoint)
			enclosingScene.physicsWorld.add(otherJoint)
		}
		
	}
	

}
