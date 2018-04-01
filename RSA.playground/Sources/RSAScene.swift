//
//  RSAScene.swift
//  wwdc-2018
//
//  Created by Bradley Mackey on 22/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

/// a scene that implements shared functionality between the intro scene and interactive scene
public class RSAScene: SKScene, SKPhysicsContactDelegate {
	
	// MARK: - Properties
	
	/// keeps track of the scene's current state
	public lazy var sceneStateMachine: GKStateMachine = {
		let machine = GKStateMachine(states: [SceneWaitState(),
											  SceneAnimatingState()])
		machine.enter(SceneWaitState.self)
		return machine
	}()
	
	/// tracks the location of a finger, can be useful for subclasses
	public var currentFingerPosition:CGPoint?
	
	/// simply loads the key texture so we don't have to reload it for each key
	public static let keyTexture = KeySprite.textureForKey()
	
	/// the edge margin where touches stop being detected
	public static let edgeMargin:CGFloat = 5
	/// an ideally smaller edge margin for the bottom, because most things rest on the bottom of the screen
	public static let bottomEdgeMargin:CGFloat = 5
	
	/// the point that we initially touched at during a touch event (the touch point for the touch down event)
	public var initialTouchPoint:CGPoint?
	
	/// all of the keys for the scene
	/// - note: override in subclasses
	public var allKeys: [KeySprite] {
		return []
	}
	
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
		return dist > 12.0
	}
	
	// MARK: - Methods
	
	public override func sceneDidLoad() {
		super.sceneDidLoad()
		// setup the world physics
		self.setupWorldPhysics()
	}
	
	/// determines whether a point is inside our defined edge margin
	public class func insideEdgeMargin(scene: SKScene, point:CGPoint) -> Bool {
		return point.x < RSAScene.edgeMargin || point.x > scene.size.width - RSAScene.edgeMargin || point.y < RSAScene.bottomEdgeMargin || point.y > scene.size.height - RSAScene.edgeMargin
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
	
	public class func backgroundSquare(forLabel label:SKLabelNode, color:UIColor) -> SKShapeNode {
		let extraWidth = max(label.frame.size.width*1.4, label.frame.size.width+20)
		let biggerSize = CGSize(width: extraWidth, height: label.frame.size.height*1.7)
		let node = SKShapeNode(rectOf: biggerSize, cornerRadius: 10)
		node.isAntialiased = true
		node.fillColor = color
		node.lineWidth = 5
		node.strokeColor = color
		node.zPosition = 0.1
		return node
	}
	
	/// the physics for the world
	public func setupWorldPhysics() {
		self.physicsWorld.contactDelegate = self
		self.physicsWorld.gravity = CGVector(dx: 0, dy: -8)
		self.physicsBody = RSAScene.worldPhysicsBody(frame: self.frame)
	}
	
	/// moves a node above another node
	public func move(node:SKNode, above mainNode:SKNode, by amount:CGFloat) {
		let point = CGPoint(x: mainNode.position.x, y: mainNode.position.y+amount)
		let moveToPosition = SKAction.move(to: point, duration: 0.01)
		node.run(moveToPosition)
	}
	
	/// the animation that should run when the incorrect key is brought to the box
	public func setSceneNotAnimating(afterDelay delay:TimeInterval) {
		let wait = SKAction.wait(forDuration: delay)
		let notAnimating = SKAction.customAction(withDuration: 0) { _, _ in
			self.sceneStateMachine.enter(SceneWaitState.self)
		}
		let notAnimatingSequence = SKAction.sequence([wait,notAnimating])
		self.run(notAnimatingSequence)
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
	
	/// uses the gameplaykit state machines to stop the keys from moving if it needs to
	public func stopKeysMovingIfNeeded(at point:CGPoint) {
		for key in allKeys {
			// set the wait state stopping point
			if let waitState = key.stateMachine.state(forClass: KeyWaitState.self) {
				waitState.stopMovingPoint = point
			}
			// enter both keys into the waiting state if applicable
			if let state = key.stateMachine.currentState, state.isKind(of: KeyDragState.self) {
				key.stateMachine.enter(KeyWaitState.self)
			}
		}
	}

}
