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

extension UIImage {
	class func image(from layer: CALayer) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(layer.bounds.size,
											   layer.isOpaque, UIScreen.main.scale)
		
		defer { UIGraphicsEndImageContext() }
		
		// Don't proceed unless we have context
		guard let context = UIGraphicsGetCurrentContext() else {
			return nil
		}
		
		layer.render(in: context)
		return UIGraphicsGetImageFromCurrentImageContext()
	}
}

final public class IntroScene: SKScene, SKPhysicsContactDelegate {
	
	var publicKeyNode:SKSpriteNode?
	var privateKeyNode:SKSpriteNode?
	
	var paper:SCNNode!
	var paperGeometry:SCNBox!
	
	var paperBig = true
	
	lazy var scnScene: SCNScene = {
		let scnScene = SCNScene()
		
		let layer = CALayer()
		layer.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
		layer.backgroundColor = UIColor.white.cgColor
		layer.contentsGravity = kCAGravityCenter
		
		var textLayer = CATextLayer()
		textLayer.frame = layer.bounds.insetBy(dx: 15, dy: 15)
		textLayer.font = CTFontCreateWithName("Courier" as CFString, 6, nil)
		textLayer.string = "Here's to the crazy ones. The misfits. The troublemakers. The round pegs in the square holes."
		textLayer.isWrapped = true
		textLayer.fontSize = 23
		textLayer.contentsGravity = kCAGravityCenter
		textLayer.alignmentMode = kCAAlignmentLeft
		textLayer.foregroundColor = UIColor.black.cgColor
		textLayer.display()
		layer.addSublayer(textLayer)
		
		
		paperGeometry = SCNBox(width: 5, height: 8, length: 0.7, chamferRadius: 0)
		let textMaterial = SCNMaterial()
		// render the layer to an UIImage to prevent display issue
		textMaterial.diffuse.contents = UIImage.image(from: layer)
		textMaterial.locksAmbientWithDiffuse = true
		let whiteMaterial = SCNMaterial()
		whiteMaterial.diffuse.contents = UIColor.white
		whiteMaterial.locksAmbientWithDiffuse = true
		paperGeometry.materials = [textMaterial, whiteMaterial, textMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
		paper = SCNNode(geometry: paperGeometry)
		paper.eulerAngles = SCNVector3(x: 0.5, y: 1, z: 0)
		scnScene.rootNode.addChildNode(paper)
		
		return scnScene
	}()
	
	struct PhysicsCategory {
		static let none:UInt32        = 0
		static let all:UInt32         = UInt32.max
		static let publicKey:UInt32   = 1 << 0
		static let privateKey:UInt32  = 1 << 1
		static let box:UInt32         = 1 << 2
		static let boundry:UInt32     = 1 << 3
	}
	
	override public func sceneDidLoad() {
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
	
	override public func didMove(to view: SKView) {
		super.didMove(to: view)
		
		
		let node = SK3DNode(viewportSize: CGSize(width: 150, height: 150))
		node.scnScene = scnScene
		node.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
		node.name = "3dnode"
		node.physicsBody = SKPhysicsBody(circleOfRadius: 50)
		node.physicsBody?.categoryBitMask = PhysicsCategory.box
		node.physicsBody?.contactTestBitMask = PhysicsCategory.publicKey | PhysicsCategory.privateKey
		node.physicsBody?.collisionBitMask = PhysicsCategory.none
		node.physicsBody?.affectedByGravity = false
		let camera = SCNCamera()
		camera.usesOrthographicProjection = true
		camera.orthographicScale = 8
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
		
		
		let keyTexture = SKTexture(imageNamed: "key-icon")
		
		
		self.publicKeyNode = SKSpriteNode(imageNamed: "key-icon")
		self.publicKeyNode?.size = CGSize(width: 50, height: 50)
		self.publicKeyNode?.colorBlendFactor = 1
		self.publicKeyNode?.color = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
		
		if let l = self.publicKeyNode {
			l.alpha = 1
			l.name = "publicKeyNode"
			l.position = CGPoint(x: self.size.width/4, y: self.size.height/4)
			l.physicsBody = SKPhysicsBody(texture: keyTexture, size: CGSize(width: 50, height: 50))
			l.physicsBody?.categoryBitMask = PhysicsCategory.publicKey
			l.physicsBody?.contactTestBitMask = PhysicsCategory.box
			l.physicsBody?.affectedByGravity = true
			l.physicsBody?.collisionBitMask = PhysicsCategory.publicKey | PhysicsCategory.privateKey | PhysicsCategory.boundry
			l.physicsBody?.allowsRotation = true
			l.physicsBody?.restitution = 0.1
			l.physicsBody?.mass = 0.5
			self.addChild(l)
		}
		
		self.privateKeyNode = SKSpriteNode(imageNamed: "key-icon")
		self.privateKeyNode?.size = CGSize(width: 50, height: 50)
		self.privateKeyNode?.colorBlendFactor = 1
		self.privateKeyNode?.color = .red
		
		if let l = self.privateKeyNode {
			l.alpha = 1
			l.name = "privateKeyNode"
			l.position = CGPoint(x: 3*self.size.width/4, y: self.size.height/4)
			l.physicsBody = SKPhysicsBody(texture: keyTexture, size: CGSize(width: 50, height: 50))
			l.physicsBody?.categoryBitMask = PhysicsCategory.privateKey
			l.physicsBody?.contactTestBitMask = PhysicsCategory.box
			l.physicsBody?.affectedByGravity = true
			l.physicsBody?.collisionBitMask = PhysicsCategory.publicKey | PhysicsCategory.privateKey | PhysicsCategory.boundry
			l.physicsBody?.allowsRotation = true
			l.physicsBody?.restitution = 0.1
			l.physicsBody?.mass = 0.5
			self.addChild(l)
		}
		
	}
	
	var movingPublicKey = false
	var movingPrivateKey = false
	var movingBox = false
	var lastPublicKeyPoint:CGPoint?
	var lastPrivateKeyPoint:CGPoint?
	var lastBoxPoint:CGPoint?
	
	func touchDown(atPoint pos : CGPoint) {
		let node = self.atPoint(pos)
		if node.name == "publicKeyNode" {
			movingPublicKey = true
			self.publicKeyNode?.removeAllActions()
			
			let moveAnimation = SKAction.move(to: pos, duration: 0.04)
			self.publicKeyNode?.run(moveAnimation)
			self.publicKeyNode?.physicsBody?.affectedByGravity = false
			self.publicKeyNode?.physicsBody?.isDynamic = false
			lastPublicKeyPoint = pos
		} else if node.name == "privateKeyNode" {
			movingPrivateKey = true
			self.privateKeyNode?.removeAllActions()
			
			let moveAnimation = SKAction.move(to: pos, duration: 0.04)
			self.privateKeyNode?.run(moveAnimation)
			self.privateKeyNode?.physicsBody?.affectedByGravity = false
			self.privateKeyNode?.physicsBody?.isDynamic = false
			lastPrivateKeyPoint = pos
		} else if node.name == "3dnode" {
			movingBox = true
			lastBoxPoint = pos
		}
		
	}
	
	func touchMoved(toPoint pos : CGPoint) {
		if movingPrivateKey {
			let moveAnimation = SKAction.move(to: pos, duration: 0.02)
			self.privateKeyNode?.run(moveAnimation)
			
			lastPrivateKeyPoint = pos
		}
		if movingPublicKey {
			let moveAnimation = SKAction.move(to: pos, duration: 0.02)
			self.publicKeyNode?.run(moveAnimation)
			
			lastPublicKeyPoint = pos
		}
		if movingBox {
			if let point = lastBoxPoint {
				let rotate = SCNAction.rotateBy(x: (point.y - pos.y)/80, y: (pos.x - point.x)/80, z: 0, duration: 0.03)
				paper.runAction(rotate)
			}
			lastBoxPoint = pos
		}
		
		
	}
	
	func touchUp(atPoint pos : CGPoint) {
		print("touch up")
		
		if movingPrivateKey {
			self.privateKeyNode?.removeAllActions()
			
			self.privateKeyNode?.physicsBody?.isDynamic = true
			self.privateKeyNode?.physicsBody?.affectedByGravity = true
			if let point = lastPrivateKeyPoint {
				let moveX = pos.x - point.x
				var moveY = pos.y - point.y
				if moveY > 0 {
					moveY *= 2
				}
				let vec = CGVector(dx: moveX*25, dy: moveY*25)
				let fling = SKAction.applyImpulse(vec, duration: 0.005)
				self.privateKeyNode?.run(fling)
			}
		}
		if movingPublicKey {
			self.publicKeyNode?.removeAllActions()
			
			self.publicKeyNode?.physicsBody?.isDynamic = true
			self.publicKeyNode?.physicsBody?.affectedByGravity = true
			if let point = lastPublicKeyPoint {
				let moveX = pos.x - point.x
				var moveY = pos.y - point.y
				if moveY > 0 {
					moveY *= 2
				}
				let vec = CGVector(dx: moveX*25, dy: moveY*25)
				let fling = SKAction.applyImpulse(vec, duration: 0.005)
				self.publicKeyNode?.run(fling)
			}
		}
		movingBox = false
		movingPublicKey = false
		movingPrivateKey = false
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
		
		if (firstBody.categoryBitMask == PhysicsCategory.publicKey && secondBody.categoryBitMask == PhysicsCategory.box) {
			
			if paperBig {
				
				let layer = CALayer()
				layer.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
				layer.backgroundColor = UIColor.black.cgColor
				
				let textLayer = CATextLayer()
				textLayer.frame = layer.bounds.insetBy(dx: 10, dy: 10)

				textLayer.string = "kuhit67683o aiyefgo6217tyg8£^&Rkjdnf &cisudfyg8&^ uvisudgf87t*F&%Rgiusgdfg8i g8r7r3sr2q3trdz iuishug08y9 7g&^R&^Giusid bfiyg87tgiwubfo776r 737tf^$Euhir  g97hiu87IGI &T8ugoeihrgo8h iy89ywieufiuiYGYTFI Uiusd97fiw uebiufg87ts87f wouefiuwfuyc a98y8w7egf ihoih891729347tewgdf9guiw"
				textLayer.isWrapped = true
				textLayer.truncationMode = kCATruncationNone
				
				textLayer.contentsGravity = kCAGravityCenter
				textLayer.alignmentMode = kCAAlignmentLeft
				textLayer.font = CTFontCreateWithName("Courier" as CFString, 35, nil)
				textLayer.foregroundColor = UIColor.white.cgColor
				textLayer.fontSize = 23
				textLayer.display()
				layer.addSublayer(textLayer)
				
				let textMaterial = SCNMaterial()
				// render layer to UIImage to prevent simulator display issue
				textMaterial.diffuse.contents = UIImage.image(from: layer)
				textMaterial.locksAmbientWithDiffuse = true
				self.paperGeometry.materials = [textMaterial, textMaterial, textMaterial, textMaterial, textMaterial, textMaterial]
				
				SCNTransaction.begin()
				SCNTransaction.animationDuration = 0.6
				paperGeometry.height = 5
				paperGeometry.length = 5
				paperGeometry.width = 5
				SCNTransaction.commit()
				
				self.paperBig = false
			} else {
				
				let grow = SCNAction.scale(to: 1.1, duration: 0.1)
				let fade = SCNAction.fadeOpacity(to: 0.1, duration: 0.1)
				let begin = SCNAction.group([grow,fade])
				let shrink = SCNAction.scale(to: 1, duration: 0.1)
				let fadeBack = SCNAction.fadeOpacity(to: 1, duration: 0.1)
				let end = SCNAction.group([shrink,fadeBack])
				let pulse = SCNAction.sequence([begin,end])
				paper.runAction(pulse)
				
				
				//				let redMaterial = SCNMaterial()
				//				redMaterial.diffuse.contents = UIColor.red
				//				redMaterial.locksAmbientWithDiffuse = true
				//				self.paperGeometry.materials = [redMaterial, redMaterial, redMaterial, redMaterial, redMaterial, redMaterial]
				//
				//
				//				SCNTransaction.begin()
				//				SCNTransaction.animationDuration = 0.15
				//				paperGeometry.height = 6
				//				paperGeometry.length = 6
				//				paperGeometry.width = 6
				//				SCNTransaction.completionBlock = {
				//					let layer = CALayer()
				//					layer.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
				//					layer.backgroundColor = UIColor.black.cgColor
				//
				//					let textLayer = CATextLayer()
				//					textLayer.frame = layer.bounds
				//					textLayer.string = "kuhit67683o aiyefgo6217tyg8£^&Rkjdnf &cisudfyg8&^ uvisudgf87t*F&%Rgiusgdfg8i g8r7r3sr2q3trdz iuishug08y9 7g&^R&^Giusid bfiyg87tgiwubfo776r 737tf^$Euhir  g97hiu87IGI &T8ugoeihrgo8h iy89ywieufiuiYGYTFI Uiusd97fiw uebiufg87ts87f wouefiuwfuyc a98y8w7egf ihoih891729347tewgdf9guiw"
				//					textLayer.isWrapped = true
				//					textLayer.truncationMode = kCATruncationNone
				//					textLayer.contentsGravity = kCAGravityCenter
				//					textLayer.alignmentMode = kCAAlignmentLeft
				//					textLayer.font = CTFontCreateWithName("Courier" as CFString, 35, nil)
				//					textLayer.foregroundColor = UIColor.white.cgColor
				//					textLayer.display()
				//					layer.addSublayer(textLayer)
				//
				//					let textMaterial = SCNMaterial()
				//					// render layer to UIImage to prevent simulator display issue
				//					textMaterial.diffuse.contents = UIImage.image(from: layer)
				//					textMaterial.locksAmbientWithDiffuse = true
				//					self.paperGeometry.materials = [textMaterial, textMaterial, textMaterial, textMaterial, textMaterial, textMaterial]
				//
				//					SCNTransaction.begin()
				//					SCNTransaction.animationDuration = 0.15
				//					self.paperGeometry.height = 5
				//					self.paperGeometry.length = 5
				//					self.paperGeometry.width = 5
				//					SCNTransaction.commit()
				//				}
				//				SCNTransaction.commit()
				
			}
		}
		else if (firstBody.categoryBitMask == PhysicsCategory.privateKey && secondBody.categoryBitMask == PhysicsCategory.box) {
			if !paperBig {
				let layer = CALayer()
				layer.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
				layer.backgroundColor = UIColor.white.cgColor
				
				let textLayer = CATextLayer()
				textLayer.frame = layer.bounds.insetBy(dx: 15, dy: 15)
				textLayer.font = CTFontCreateWithName("Courier" as CFString, 6, nil)
				textLayer.string = "Here's to the crazy ones. The misfits. The troublemakers. The round pegs in the square holes."
				textLayer.fontSize = 23
				textLayer.isWrapped = true
				textLayer.contentsGravity = kCAGravityCenter
				textLayer.alignmentMode = kCAAlignmentLeft
				textLayer.foregroundColor = UIColor.black.cgColor
				textLayer.display()
				layer.addSublayer(textLayer)
				
				let textMaterial = SCNMaterial()
				// render layer to UIImage to prevent simulator display issue
				textMaterial.diffuse.contents = UIImage.image(from: layer)
				textMaterial.locksAmbientWithDiffuse = true
				let whiteMaterial = SCNMaterial()
				whiteMaterial.diffuse.contents = UIColor.white
				whiteMaterial.locksAmbientWithDiffuse = true
				self.paperGeometry.materials = [textMaterial, whiteMaterial, textMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
				
				
				SCNTransaction.begin()
				SCNTransaction.animationDuration = 0.6
				paperGeometry.height = 8
				paperGeometry.width = 5
				paperGeometry.length = 0.7
				SCNTransaction.commit()
				
				paperBig = true
			} else {
				
				let grow = SCNAction.scale(to: 1.1, duration: 0.1)
				let fade = SCNAction.fadeOpacity(to: 0.1, duration: 0.1)
				let begin = SCNAction.group([grow,fade])
				let shrink = SCNAction.scale(to: 1, duration: 0.1)
				let fadeBack = SCNAction.fadeOpacity(to: 1, duration: 0.1)
				let end = SCNAction.group([shrink,fadeBack])
				let pulse = SCNAction.sequence([begin,end])
				paper.runAction(pulse)
				
				//				let redMaterial = SCNMaterial()
				//				redMaterial.diffuse.contents = UIColor.red
				//				redMaterial.locksAmbientWithDiffuse = true
				//				self.paperGeometry.materials = [redMaterial, redMaterial, redMaterial, redMaterial, redMaterial, redMaterial]
				//
				//
				//				SCNTransaction.begin()
				//				SCNTransaction.animationDuration = 0.15
				//				paperGeometry.height = 9
				//				paperGeometry.width = 6
				//				paperGeometry.length = 1
				//				SCNTransaction.completionBlock = {
				//					let layer = CALayer()
				//					layer.frame = CGRect(x: 0, y: 0, width: 300, height: 450)
				//					layer.backgroundColor = UIColor.white.cgColor
				//
				//					let textLayer = CATextLayer()
				//					textLayer.frame = layer.bounds
				//					textLayer.font = CTFontCreateWithName("Courier" as CFString, 16, nil)
				//					textLayer.string = "Here's to the crazy ones. The misfits. The round pegs in the square holes."
				//					textLayer.isWrapped = true
				//					textLayer.contentsGravity = kCAGravityCenter
				//					textLayer.alignmentMode = kCAAlignmentLeft
				//					textLayer.foregroundColor = UIColor.black.cgColor
				//					textLayer.display()
				//					layer.addSublayer(textLayer)
				//
				//					let textMaterial = SCNMaterial()
				//					// render layer to UIImage to prevent simulator display issue
				//					textMaterial.diffuse.contents = UIImage.image(from: layer)
				//					textMaterial.locksAmbientWithDiffuse = true
				//					let whiteMaterial = SCNMaterial()
				//					whiteMaterial.diffuse.contents = UIColor.white
				//					whiteMaterial.locksAmbientWithDiffuse = true
				//					self.paperGeometry.materials = [textMaterial, whiteMaterial, textMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
				//
				//					SCNTransaction.begin()
				//					SCNTransaction.animationDuration = 0.15
				//					self.paperGeometry.height = 8
				//					self.paperGeometry.width = 5
				//					self.paperGeometry.length = 0.7
				//					SCNTransaction.commit()
				//				}
				//				SCNTransaction.commit()
				
			}
		}
	}
	
	override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		for t in touches {
			self.touchDown(atPoint: t.location(in: self))
		}
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
	
	override public func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
	}
	
	
}

