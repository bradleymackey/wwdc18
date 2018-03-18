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
	var paperGeometry:SCNBox!
	
	var paperBig = true
	
	lazy var scnScene: SCNScene = {
		let scnScene = SCNScene()
		
		let layer = CALayer()
		layer.frame = CGRect(x: 0, y: 0, width: 300, height: 450)
		layer.backgroundColor = UIColor.white.cgColor
		
		var textLayer = CATextLayer()
		textLayer.frame = layer.bounds
		textLayer.font = CTFontCreateWithName("Courier" as CFString, 16, nil)
		textLayer.string = "Here's to the crazy ones. The misfits. The round pegs in the square holes."
		textLayer.isWrapped = true
		textLayer.contentsGravity = kCAGravityCenter
		textLayer.alignmentMode = kCAAlignmentLeft
		textLayer.foregroundColor = UIColor.black.cgColor
		textLayer.display()
		layer.addSublayer(textLayer)

		
		paperGeometry = SCNBox(width: 5, height: 8, length: 0.7, chamferRadius: 0)
		let textMaterial = SCNMaterial()
		textMaterial.diffuse.contents = layer
		textMaterial.locksAmbientWithDiffuse = true
		let whiteMaterial = SCNMaterial()
		whiteMaterial.diffuse.contents = UIColor.white
		whiteMaterial.locksAmbientWithDiffuse = true
		paperGeometry.materials = [textMaterial, whiteMaterial, textMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
		paper = SCNNode(geometry: paperGeometry)
		paper.eulerAngles = SCNVector3(x: 0.5, y: 1, z: 0)
		scnScene.rootNode.addChildNode(paper)
		let translate = SCNVector3(x: 20, y: 20, z: 0)
		
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
		
		
		let node = SK3DNode(viewportSize: CGSize(width: 200, height: 200))
		node.scnScene = scnScene
		node.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
		node.name = "3dnode"
		node.physicsBody = SKPhysicsBody(circleOfRadius: 50)
		node.physicsBody?.categoryBitMask = PhysicsCategory.box
		node.physicsBody?.contactTestBitMask = PhysicsCategory.key
		node.physicsBody?.collisionBitMask = PhysicsCategory.none
		node.physicsBody?.affectedByGravity = false
		let camera = SCNCamera()
		camera.usesOrthographicProjection = true
		camera.orthographicScale = 6
		let cameraNode = SCNNode()
		cameraNode.camera = camera
		if let lookAtTarget = scnScene.rootNode.childNodes.first {
			let constraint = SCNLookAtConstraint(target: lookAtTarget)
			cameraNode.constraints = [ constraint ]
		}
		node.pointOfView = cameraNode
		node.pointOfView?.position = SCNVector3(x: 0, y: 0, z: 70)
		let rotate = SCNAction.rotate(by: .pi, around: SCNVector3(x: 0, y: 1, z: 0), duration: 7)
		let rotateForever = SCNAction.repeatForever(rotate)
		scnScene.rootNode.runAction(rotateForever)
		self.addChild(node)
		
		
		self.label = SKLabelNode(fontNamed: "Helvetica")
		
		if let l = self.label {
			l.alpha = 1
			l.name = "label"
			l.text = "🔑"
			l.fontColor = .red
			l.fontSize = 80
			l.position = CGPoint(x: self.size.width/4, y: self.size.height/4)
			l.physicsBody = SKPhysicsBody(circleOfRadius: l.frame.width/1.5)
			l.physicsBody?.categoryBitMask = PhysicsCategory.key
			l.physicsBody?.contactTestBitMask = PhysicsCategory.box
			l.physicsBody?.affectedByGravity = true
			l.physicsBody?.collisionBitMask = PhysicsCategory.key | PhysicsCategory.boundry
			l.physicsBody?.allowsRotation = true
			l.physicsBody?.restitution = 0.1
			self.addChild(l)
		}
		
		
	}
	
	var movingLabel = false
	var movingBox = false
	var lastLabelPoint:CGPoint?
	var lastBoxPoint:CGPoint?
	
	func touchDown(atPoint pos : CGPoint) {
		let node = self.atPoint(pos)
		if node.name == "label" {
			movingLabel = true
			self.label?.removeAllActions()
			
			let moveAnimation = SKAction.move(to: pos, duration: 0.04)
			self.label?.run(moveAnimation)
			self.label?.physicsBody?.affectedByGravity = false
			self.label?.physicsBody?.isDynamic = false
			lastLabelPoint = pos
		} else if node.name == "3dnode" {
			movingBox = true
			lastBoxPoint = pos
		}
		
	}
	
	func touchMoved(toPoint pos : CGPoint) {
		if movingLabel {
			let moveAnimation = SKAction.move(to: pos, duration: 0.02)
			self.label?.run(moveAnimation)
			
			lastLabelPoint = pos
		}
		if movingBox {
			if let point = lastBoxPoint {
				let rotate = SCNAction.rotateBy(x: (point.y - pos.y)/80, y: (pos.x - point.x)/80, z: 0, duration: 0.02)
				paper.runAction(rotate)
			}
			lastBoxPoint = pos
		}
		
		
	}
	
	func touchUp(atPoint pos : CGPoint) {
		print("touch up")
		if movingLabel {
			self.label?.removeAllActions()
			movingLabel = false
			self.label?.physicsBody?.isDynamic = true
			self.label?.physicsBody?.affectedByGravity = true
			if let point = lastLabelPoint {
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
		if movingBox {
			movingBox = false
		}
		
	}
	
	func didBegin(_ contact: SKPhysicsContact) {
		var firstBody: SKPhysicsBody
		var secondBody: SKPhysicsBody
		if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
			firstBody = contact.bodyA
			secondBody = contact.bodyB
		} else {
			firstBody = contact.bodyB
			secondBody = contact.bodyA
		}
		
		if (firstBody.categoryBitMask == PhysicsCategory.key && secondBody.categoryBitMask == PhysicsCategory.box) {
//			let fade = SKAction.fadeAlpha(to: 0, duration: 0.2)
//			let remove = SKAction.removeFromParent()
//			let seq = SKAction.sequence([fade,remove])
//			firstBody.node?.run(seq)
			if paperBig {
				
				let layer = CALayer()
				layer.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
				layer.backgroundColor = UIColor.black.cgColor
				
				let textLayer = CATextLayer()
				textLayer.frame = layer.bounds
				textLayer.string = "kuhit67683o aiyefgo6217tyg8£^&Rkjdnf &cisudfyg8&^ uvisudgf87t*F&%Rgiusgdfg8i g8r7r3sr2q3trdz iuishug08y9 7g&^R&^Giusid bfiyg87tgiwubfo776r 737tf^$Euhir  g97hiu87IGI &T8ugoeihrgo8h iy89ywieufiuiYGYTFI Uiusd97fiw uebiufg87ts87f wouefiuwfuyc a98y8w7egf ihoih891729347tewgdf9guiw"
				textLayer.isWrapped = true
				textLayer.truncationMode = kCATruncationNone
				textLayer.contentsGravity = kCAGravityCenter
				textLayer.alignmentMode = kCAAlignmentLeft
				textLayer.font = CTFontCreateWithName("Courier" as CFString, 35, nil)
				textLayer.foregroundColor = UIColor.white.cgColor
				textLayer.display()
				layer.addSublayer(textLayer)
				
				let textMaterial = SCNMaterial()
				textMaterial.diffuse.contents = layer
				textMaterial.locksAmbientWithDiffuse = true
				self.paperGeometry.materials = [textMaterial, textMaterial, textMaterial, textMaterial, textMaterial, textMaterial]
				
				SCNTransaction.begin()
				SCNTransaction.animationDuration = 0.6
				paperGeometry.height = 5
				paperGeometry.length = 5
				SCNTransaction.commit()
				
				self.paperBig = false
			} else {
				
				let layer = CALayer()
				layer.frame = CGRect(x: 0, y: 0, width: 300, height: 450)
				layer.backgroundColor = UIColor.white.cgColor
				
				let textLayer = CATextLayer()
				textLayer.frame = layer.bounds
				textLayer.font = CTFontCreateWithName("Courier" as CFString, 16, nil)
				textLayer.string = "Here's to the crazy ones. The misfits. The round pegs in the square holes."
				textLayer.isWrapped = true
				textLayer.contentsGravity = kCAGravityCenter
				textLayer.alignmentMode = kCAAlignmentLeft
				textLayer.foregroundColor = UIColor.black.cgColor
				textLayer.display()
				layer.addSublayer(textLayer)
				
				let textMaterial = SCNMaterial()
				textMaterial.diffuse.contents = layer
				textMaterial.locksAmbientWithDiffuse = true
				let whiteMaterial = SCNMaterial()
				whiteMaterial.diffuse.contents = UIColor.white
				whiteMaterial.locksAmbientWithDiffuse = true
				self.paperGeometry.materials = [textMaterial, whiteMaterial, textMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
				
				
				SCNTransaction.begin()
				SCNTransaction.animationDuration = 0.6
				paperGeometry.height = 8
				paperGeometry.length = 0.7
				SCNTransaction.commit()
				
				paperBig = true
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
