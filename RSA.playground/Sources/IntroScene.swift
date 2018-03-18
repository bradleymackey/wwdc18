//
//  IntroScene.swift
//  nothing
//
//  Created by Bradley Mackey on 18/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation

import SpriteKit
import SceneKit

final class IntroScene: SKScene, SKPhysicsContactDelegate {
	
	var label:SKLabelNode?
	
	var paper:SCNNode!
	
	lazy var scnScene: SCNScene = {
		let scnScene = SCNScene()
		
		//let torusGeometry = SCNTorus(ringRadius: 10, pipeRadius: 3)
		let paperGeometry = SCNBox(width: 5, height: 8, length: 0.7, chamferRadius: 0)
		let paperMaterial = SCNMaterial()
		//paperMaterial.diffuse.contents = UIColor.white
		paperMaterial.ambient.contents = UIColor.white
		paperGeometry.materials = [paperMaterial]
		paper = SCNNode(geometry: paperGeometry)
		let paperShape = SCNPhysicsShape(geometry: paperGeometry, options: nil)
		paper.eulerAngles = SCNVector3(x: 0.5, y: 1, z: 0)
		scnScene.rootNode.addChildNode(paper)
		let translate = SCNVector3(x: 20, y: 20, z: 0)
		
		SCNTransaction.begin()
		SCNTransaction.animationDuration = 5
		paperGeometry.height = 5
		paperGeometry.length = 5
		SCNTransaction.completionBlock = {
			SCNTransaction.begin()
			SCNTransaction.animationDuration = 1
			paperGeometry.height = 8
			paperGeometry.length = 0.7
			SCNTransaction.commit()
		}
		SCNTransaction.commit()
		return scnScene
	}()

	struct PhysicsCategory {
		static let none:UInt32    = 0
		static let all:UInt32     = UInt32.max
		static let key:UInt32     = 1 << 0
		static let box:UInt32     = 1 << 1
		static let boundry:UInt32 = 1 << 2
	}
	
	override func sceneDidLoad() {
		super.sceneDidLoad()
		self.backgroundColor = .white
		
		self.physicsWorld.contactDelegate = self
		self.physicsWorld.gravity = CGVector(dx: 0, dy: -6)
		self.physicsBody = SKPhysicsBody(edgeLoopFrom: self.frame)
		self.physicsBody?.affectedByGravity = false
		self.physicsBody?.categoryBitMask = PhysicsCategory.boundry
		self.physicsBody?.contactTestBitMask = PhysicsCategory.none
		self.physicsBody?.collisionBitMask = PhysicsCategory.all
	}
	
	override func didMove(to view: SKView) {
		super.didMove(to: view)
		self.label = SKLabelNode(fontNamed: "Helvetica")
		
		let node = SK3DNode(viewportSize: CGSize(width: self.size.width, height: self.size.height))
		node.scnScene = scnScene
		node.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
		node.name = "3dnode"
		let camera = SCNCamera()
		camera.usesOrthographicProjection = true
		camera.orthographicScale = 30
		let cameraNode = SCNNode()
		cameraNode.camera = camera
		if let lookAtTarget = scnScene.rootNode.childNodes.first {
			let constraint = SCNLookAtConstraint(target: lookAtTarget)
			cameraNode.constraints = [ constraint ]
		}
		node.pointOfView = cameraNode
		node.pointOfView?.position = SCNVector3(x: 0, y: 0, z: 70)
//		let rotate = SCNAction.rotate(by: .pi, around: SCNVector3(x: 0, y: 1, z: 0), duration: 7)
//		let rotateForever = SCNAction.repeatForever(rotate)
//		cameraNode.runAction(rotateForever)
		self.addChild(node)
		
		
		if let l = self.label {
			l.alpha = 1
			l.name = "label"
			l.text = "Testing!"
			l.fontColor = .red
			l.fontSize = 20
			l.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
			l.physicsBody = SKPhysicsBody(circleOfRadius: l.frame.width/2)
			l.physicsBody?.categoryBitMask = PhysicsCategory.key
			l.physicsBody?.contactTestBitMask = PhysicsCategory.box
			l.physicsBody?.affectedByGravity = true
			l.physicsBody?.collisionBitMask = PhysicsCategory.all
			l.physicsBody?.allowsRotation = true
			l.physicsBody?.restitution = 0.1
			self.addChild(l)
		}
		
		
	}
	
	var movingLabel = false
	var lastPoint:CGPoint?
	
	func touchDown(atPoint pos : CGPoint) {
		let node = self.atPoint(pos)
		if node.name == "label" {
			movingLabel = true
			self.label?.removeAllActions()
			
			let moveAnimation = SKAction.move(to: pos, duration: 0.04)
			self.label?.run(moveAnimation)
			self.label?.physicsBody?.affectedByGravity = false
			//self.label?.physicsBody?.isDynamic = false
			lastPoint = pos
		}
		
	}
	
	func touchMoved(toPoint pos : CGPoint) {
		if movingLabel {
			let moveAnimation = SKAction.move(to: pos, duration: 0.02)
			self.label?.run(moveAnimation)
			if let point = lastPoint {
				let rotate = SCNAction.rotateBy(x: (pos.x - point.x)/40, y: (pos.y - point.y)/40, z: 0, duration: 0.02)
				paper.runAction(rotate)
			}
			lastPoint = pos
			
		}
		
	}
	
	func touchUp(atPoint pos : CGPoint) {
		print("touch up")
		if movingLabel {
			self.label?.removeAllActions()
			movingLabel = false
			//self.label?.physicsBody?.isDynamic = true
			self.label?.physicsBody?.affectedByGravity = true
			if let point = lastPoint {
				let moveX = pos.x - point.x
				var moveY = pos.y - point.y
				if moveY > 0 {
					moveY *= 2
				}
				let vec = CGVector(dx: moveX*25, dy: moveY*25)
				let fling = SKAction.applyImpulse(vec, duration: 0.005)
				self.label?.run(fling)
			}
		}
		
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			self.touchDown(atPoint: t.location(in: self))
		}
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self)) }
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches { self.touchUp(atPoint: t.location(in: self)) }
	}
	
	override func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
	}
	
	
}
