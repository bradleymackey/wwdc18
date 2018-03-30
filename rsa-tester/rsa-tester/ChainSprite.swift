//
//  RopeSprite.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 26/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

public final class ChainSprite: SKNode {
	
	public let attachmentPoint:CGPoint
	public let attachedElement:SKSpriteNode
	private var chainLinks = [SKSpriteNode]()
	
	required public init(attachmentPoint:CGPoint, attachedElement:SKSpriteNode, length:Int) {
		self.attachmentPoint = attachmentPoint
		self.attachedElement = attachedElement
		super.init()
		self.setChainLength(length: length)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setChainLength(length:Int) {
		// add the links that we will use
		for linkNumber in 0..<length {
            let link = ChainSprite.newLinkSprite()
			link.position = CGPoint(x: self.attachmentPoint.x, y: self.attachmentPoint.y-(CGFloat(linkNumber)*(link.size.width)))
			chainLinks.append(link)
		}
		// add the element that we will attach as well
		guard let previous = chainLinks.last else { return }
		attachedElement.position = CGPoint(x: previous.position.x, y: previous.frame.minY)
		chainLinks.append(attachedElement)
	}
    
    /// creates a new chain link sprite
    private class func newLinkSprite() -> SKSpriteNode {
        let link = SKSpriteNode(imageNamed: "circle.png")
        link.size = CGSize(width: 5, height: 5)
        link.physicsBody = SKPhysicsBody(circleOfRadius: link.size.height)
        link.physicsBody?.categoryBitMask = PhysicsCategory.chainLink
        link.physicsBody?.collisionBitMask = PhysicsCategory.boundry | PhysicsCategory.keys
        link.physicsBody?.contactTestBitMask = PhysicsCategory.none
        link.physicsBody?.allowsRotation = true
        link.physicsBody?.isDynamic = true
        return link
    }
	
    public func addChainElementsToScene(_ enclosingScene:SKScene) {
        
        // add them to the scene
		for item in chainLinks {
			guard item.parent == nil else { continue }
			enclosingScene.addChild(item)
		}
		
		let joint = SKPhysicsJointPin.joint(withBodyA: enclosingScene.physicsBody!, bodyB: chainLinks[0].physicsBody!, anchor: attachmentPoint)
        joint.frictionTorque = 0.9
		enclosingScene.physicsWorld.add(joint)
		
		for jointNumber in 1..<(chainLinks.count) {
			var subtract = CGFloat(0)
            var friction = CGFloat(0.9)
			if jointNumber ==  chainLinks.count - 1 {
				// on the last one, subtract so the cage touches the chain
				subtract = 22
                friction = 0.05
			}
			let nodeA = chainLinks[jointNumber-1]
			let nodeB = chainLinks[jointNumber]
			let anchorPoint = CGPoint(x: nodeB.frame.midX, y: nodeB.frame.maxY-subtract)
			let otherJoint = SKPhysicsJointPin.joint(withBodyA: nodeA.physicsBody!, bodyB: nodeB.physicsBody!, anchor: anchorPoint)
            otherJoint.frictionTorque = friction
			enclosingScene.physicsWorld.add(otherJoint)
		}
		
	}
	

}
