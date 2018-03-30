//
//  RSAScene.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 22/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

/// a scene that implements shared functionality between the intro scene and interactive scene
public class RSAScene: SKScene, SKPhysicsContactDelegate {
	
	// MARK: - Properties
	
	/// tracks the location of a finger, can be useful for subclasses
	public var currentFingerPosition:CGPoint?
	
	/// simply loads the key texture so we don't have to reload it for each key
	public static let keyTexture = KeySprite.textureForKey()
	
	/// the point that we initially touched at during a touch event (the touch point for the touch down event)
	public var initialTouchPoint:CGPoint?
	
	/// whether the current touch has been deemed significant
	/// - note: this can be used to distinguish a touch action from a drag action
	public var movedSignificantlyThisTouch:Bool = false
	
	/// determines whether our touch has moved significantly since we touched it
	private var movedSignificantly:Bool {
		guard let fingerPosition = self.currentFingerPosition else { return false }
		guard let touchPoint = self.initialTouchPoint else { return false }
		let x = fingerPosition.x - touchPoint.x
		let y = fingerPosition.y - touchPoint.y
		let dist = sqrt(x*x + y*y)
		return dist > 10.0
	}
	
	// MARK: - Methods
	
	public override func sceneDidLoad() {
		super.sceneDidLoad()
		// setup the world physics
		self.setupWorldPhysics()
	}
	
	/// the basic structure of a maths labels, which all labels share
	public class func mathsLabel(text:String,fontSize:CGFloat,color:UIColor,bold:Bool) -> SKLabelNode {
		let label = SKLabelNode(fontNamed: bold ? "Courier-Bold" : "Courier")
		label.text = text
		label.fontSize = fontSize
		label.fontColor = color
		label.verticalAlignmentMode = .center
		label.horizontalAlignmentMode = .center
		return label
	}
	
	public class func worldPhysicsBody(frame:CGRect) -> SKPhysicsBody {
		let body = SKPhysicsBody(edgeLoopFrom: frame)
		body.affectedByGravity = false
		body.categoryBitMask = PhysicsCategory.boundry
		body.contactTestBitMask = PhysicsCategory.none
		body.collisionBitMask = PhysicsCategory.all
		return body
	}
	
	/// the physics for the world
	public func setupWorldPhysics() {
		self.physicsWorld.contactDelegate = self
		self.physicsWorld.gravity = CGVector(dx: 0, dy: -6)
		self.physicsBody = RSAScene.worldPhysicsBody(frame: self.frame)
	}
	
	/// moves a node above another node
	public func move(node:SKNode, above mainNode:SKNode, by amount:CGFloat) {
		let point = CGPoint(x: mainNode.position.x, y: mainNode.position.y+amount)
		let moveToPosition = SKAction.move(to: point, duration: 0.01)
		node.run(moveToPosition)
	}
	
	// MARK: Touch delegation
	
	override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchDown(atPoint: t.location(in: self)) }
	}
	
	override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
	}
	
	override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self)) }
	}
	
	override public func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self)) }
	}
	
	// MARK: Friendly touch functions
	
	public func touchDown(atPoint point: CGPoint) {
		self.currentFingerPosition = point
		self.initialTouchPoint = point
	}
	
	public func touchMoved(toPoint point: CGPoint) {
		self.currentFingerPosition = point
		// determine if we have moved our finger a significant amount
		if !self.movedSignificantlyThisTouch {
			self.movedSignificantlyThisTouch = self.movedSignificantly
		}
	}
	
	public func touchUp(atPoint point: CGPoint) {
        // on exit, set finger position to nil
        defer {
			self.currentFingerPosition = nil
			self.initialTouchPoint = nil
			self.movedSignificantlyThisTouch = false
		}
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
		// call our other nicer method
		self.bodyContact(firstBody: firstBody, secondBody: secondBody)
	}
	
    /// a more friendly `didBegin(_:)` method, where first body is always of a lower bitmask value
	public func bodyContact(firstBody:SKPhysicsBody, secondBody:SKPhysicsBody) {
		// override in subclasses
	}

}
