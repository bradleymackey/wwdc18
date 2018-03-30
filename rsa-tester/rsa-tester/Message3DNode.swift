//
//  Message3DNode.swift
//  nothing
//
//  Created by Bradley Mackey on 19/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import SceneKit

/// the spritekit node that contains the 3D scene with the message object in
public final class Message3DNode: SK3DNode, MoveableSprite {
	
	// MARK: Constants
	public static let timeForPaperRotation: TimeInterval = 2.1
	
	// MARK: Properties
	
	/// the scene that is presented inside of the node
	public let messageScene:Message3DScene
	/// whether or not the cube is being rotated
	private var isBeingRotated = false
	
	/// the last point that was registered during the cube rotation
	private var lastRotationPoint:CGPoint?
    
    /// if the message node is currently being moved
    private var isBeingMoved = false
	
	// MARK: Lifecycle
	
	required public init(viewportSize: CGSize, messageScene: Message3DScene) {
		self.messageScene = messageScene
		super.init(viewportSize: viewportSize)
		// setup
		self.setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setup() {
		// the scene that should be presented by this 3D node
		self.scnScene = messageScene
		// setup physics
		self.physicsBody = Message3DNode.physicsBody(frame: self.frame.insetBy(dx: 20, dy: 20))
		// setup point of view
		self.pointOfView = Message3DNode.cameraNode(forScene: messageScene)
		self.pointOfView?.position = SCNVector3(x: 0, y: 0, z: 70)
		// rotate the root node of the scene forever
		let rotate = SCNAction.rotate(by: .pi, around: SCNVector3(x: 0, y: .pi*2, z: 0), duration: Message3DNode.timeForPaperRotation)
		let rotateForever = SCNAction.repeatForever(rotate)
		messageScene.rootNode.runAction(rotateForever, forKey: "constantRotate")
	}
	
	// MARK: Methods
	
	private class func physicsBody(frame: CGRect) -> SKPhysicsBody {
		let body = SKPhysicsBody(circleOfRadius: frame.width/2)
		body.categoryBitMask = PhysicsCategory.box
		body.contactTestBitMask = PhysicsCategory.keys
		body.collisionBitMask = PhysicsCategory.box | PhysicsCategory.boundry | PhysicsCategory.character
		body.affectedByGravity = false
		body.allowsRotation = false // we do not allow rotation, otherwise we will get nosense looking things
		body.pinned = true // pinned so we don't move, will be toggled when we move it around
		return body
	}
	
	private class func cameraNode(forScene scene:SCNScene) -> SCNNode {
		let camera = SCNCamera()
		camera.usesOrthographicProjection = true
		camera.orthographicScale = 1.7
		let cameraNode = SCNNode()
		cameraNode.camera = camera
		if let lookAtTarget = scene.rootNode.childNodes.first {
			let constraint = SCNLookAtConstraint(target: lookAtTarget)
			cameraNode.constraints = [constraint]
		}
		return cameraNode
	}
	
	// MARK: Rotation (Intro Scene)
	
	public func startRotating(at point:CGPoint) {
		self.isBeingRotated = true
		lastRotationPoint = point
	}
	
	/// updating the angle of the rotating
	public func updateRotationIfRotating(newPoint point:CGPoint) {
		guard self.isBeingRotated else { return }
		// rotate the paper
		if let lastPoint = lastRotationPoint {
			messageScene.rotatePaper(dx: (lastPoint.y - point.y)/80, dy: (point.x - lastPoint.x)/80)
		}
		// update the last touched point
		lastRotationPoint = point
	}
	
	public func endRotation() {
		self.isBeingRotated = false
		lastRotationPoint = nil
	}
	
    
    // MARK: Moving (Interactive Scene)
    
    public func startMoving(initialPoint:CGPoint) {
        self.isBeingMoved = true
		self.physicsBody?.pinned = false
        let moveAnimation = SKAction.move(to: initialPoint, duration: 0.04)
        self.run(moveAnimation)
    }
    
    public func updatePosition(to point: CGPoint) {
        guard isBeingMoved else { return }
        let moveAnimation = SKAction.move(to: point, duration: 0.02)
        self.run(moveAnimation)
    }
    
    public func stopMoving(at lastPoint:CGPoint) {
        self.isBeingMoved = false
		self.physicsBody?.pinned = true
    }
	
}
