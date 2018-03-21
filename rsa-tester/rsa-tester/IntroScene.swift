
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

final public class IntroScene: SKScene, SKPhysicsContactDelegate {
	
	// MARK: Sprites
	var publicKeyNode:KeySprite!
	var privateKeyNode:KeySprite!
	var messageSceneNode:Message3DNode!
	
	// MARK: 3D Scene
	lazy var paperScene = Message3DScene(message: "Here's to the crazy ones. The misfits. The troublemakers. The round pegs in the square holes.")
	
	// MARK: Tracking Variables
	var currentFingerPosition:CGPoint?
	
	
	// MARK: Maths labels
	var mLabel:SKLabelNode!
	var nLabel:SKLabelNode!
	var eLabel:SKLabelNode!
	var dLabel:SKLabelNode!
	var modLabel:SKLabelNode!
	var cLabel:SKLabelNode!
	
	override public func sceneDidLoad() {
		super.sceneDidLoad()
		self.backgroundColor = .white
		// setup the physics for the world
		self.setupWorldPhysics()
	}
	
	
	override public func didMove(to view: SKView) {
		super.didMove(to: view)
		
		let sceneSize = CGSize(width: 150, height: 150)
		messageSceneNode = Message3DNode(viewportSize: sceneSize, messageScene: paperScene)
		messageSceneNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
		messageSceneNode.name = "3dnode"
		self.addChild(messageSceneNode)
		
		guard let path = Bundle.main.path(forResource: "key", ofType: "png") else {
			print("ERROR: could not get key texture")
			return
		}
		guard let data = FileManager.default.contents(atPath: path) else {
			print("ERROR: could not get key texture")
			return
		}
		guard let image = UIImage(data: data) else {
			print("ERROR: could not get key texture")
			return
		}
		
		let keyTexture = SKTexture(image: image)
		
		self.publicKeyNode = KeySprite(texture: keyTexture, color: #colorLiteral(red: 0.02509527327, green: 0.781170527, blue: 2.601820516e-16, alpha: 1), owner: .alice, type: .pub)
		self.publicKeyNode.name = "publicKeyNode"
		self.publicKeyNode.position = CGPoint(x: self.size.width/4, y: self.size.height/4)
		self.addChild(publicKeyNode)
		self.privateKeyNode = KeySprite(texture: keyTexture, color: #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1), owner: .alice, type: .priv)
		self.privateKeyNode.name = "privateKeyNode"
		self.privateKeyNode.position = CGPoint(x: 3*self.size.width/4, y: self.size.height/4)
		self.addChild(privateKeyNode)
		
		mLabel = IntroScene.mathsLabel(text: "M", fontSize: 50, color: .black, bold: true)
		mLabel.position =  CGPoint(x: self.size.width/2, y: 2.75*self.size.height/4)
		self.addChild(mLabel)
		
		nLabel = IntroScene.mathsLabel(text: "N", fontSize: 45, color: .gray, bold: false)
		nLabel.position =  CGPoint(x: self.size.width-30, y: self.size.height-30)
		self.addChild(nLabel)
		
		eLabel = IntroScene.mathsLabel(text: "e", fontSize: 30, color: .black, bold: false)
		eLabel.position =  CGPoint(x: publicKeyNode.position.x, y: publicKeyNode.position.y+30)
		self.addChild(eLabel)
		
		dLabel = IntroScene.mathsLabel(text: "d", fontSize: 30, color: .black, bold: false)
		dLabel.position =  CGPoint(x: privateKeyNode.position.x, y: privateKeyNode.position.y+30)
		self.addChild(dLabel)
		
		modLabel = IntroScene.mathsLabel(text: "mod", fontSize: 35, color: .gray, bold: false)
		modLabel.position =  CGPoint(x: self.nLabel.position.x-60, y: self.nLabel.position.y)
		self.addChild(modLabel)
		
		cLabel = IntroScene.mathsLabel(text: "C", fontSize: 50, color: .black, bold: true)
		cLabel.position = CGPoint(x: self.size.width/2, y: 2.75*self.size.height/4)
		cLabel.alpha = 0
		self.addChild(cLabel)
		
	}
	
	private class func mathsLabel(text:String,fontSize:CGFloat,color:UIColor,bold:Bool) -> SKLabelNode {
		let label = SKLabelNode(fontNamed: bold ? "Courier-Bold" : "Courier")
		label.text = text
		label.fontSize = fontSize
		label.fontColor = color
		label.verticalAlignmentMode = .center
		label.horizontalAlignmentMode = .center
		return label
	}
	
	private func setupWorldPhysics() {
		self.physicsWorld.contactDelegate = self
		self.physicsWorld.gravity = CGVector(dx: 0, dy: -6)
		self.physicsBody = IntroScene.worldPhysicsBody(frame: self.frame.insetBy(dx: 10, dy: 10))
	}
	
	private class func worldPhysicsBody(frame:CGRect) -> SKPhysicsBody {
		let body = SKPhysicsBody(edgeLoopFrom: frame)
		body.affectedByGravity = false
		body.categoryBitMask = PhysicsCategory.boundry
		body.contactTestBitMask = PhysicsCategory.none
		body.collisionBitMask = PhysicsCategory.all
		return body
	}
	
	func touchDown(atPoint point: CGPoint) {
		currentFingerPosition = point
		let node = self.atPoint(point)
		guard let nodeName = node.name else {
			return
		}
		switch (nodeName) {
		case "publicKeyNode":
			self.publicKeyNode.startMoving(initialPoint: point)
		case "privateKeyNode":
			self.privateKeyNode.startMoving(initialPoint: point)
		case "3dnode":
			self.messageSceneNode.startRotating(at: point)
		default:
			return
		}
	}
	
	func touchMoved(toPoint point: CGPoint) {
		// ignore movement if position is outside scene
		let margin:CGFloat = 15
		if point.x < margin || point.x > self.size.width - margin || point.y < margin || point.y > self.size.height - margin { return }
		// update objects if we need to
		self.messageSceneNode.updateRotationIfNeeded(newPoint: point)
		currentFingerPosition = point
	}
	
	func touchUp(atPoint pos: CGPoint) {
		// stop moving keys if they were being moved
		self.privateKeyNode.stopMoving(at: pos)
		self.publicKeyNode.stopMoving(at: pos)
		// stop rotating the message if it was being rotated
		self.messageSceneNode.finishedRotating()
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
		
		if (firstBody.categoryBitMask == PhysicsCategory.publicKeyA && secondBody.categoryBitMask == PhysicsCategory.box) {
			switch (paperScene.paperState) {
			case .unencrypted:
				self.paperScene.paperState = .encrypted
				
				let wait = SKAction.wait(forDuration: 1.5)
				let remove = SKAction.removeFromParent()
				let shrink = SKAction.scale(to: 0.6, duration: 0.4)
				shrink.timingMode = .easeIn
				let grow = SKAction.scale(to: 1, duration: 0)
				let fadeOut = SKAction.fadeOut(withDuration: 0.4)
				let centerPosition = CGPoint(x: self.size.width/2, y: mLabel.position.y)
				let moveToCenter = SKAction.move(to: centerPosition, duration: 0)
				let animateToCenter = SKAction.move(to: centerPosition, duration: 0.4)
				let shrinkAndFade = SKAction.group([shrink,fadeOut,animateToCenter])
				
				let position = CGPoint(x: (self.size.width/2)-45, y: mLabel.position.y+25)
				let moveToM = SKAction.move(to: position, duration: 0.8)
				moveToM.timingMode = .easeOut
				let eSequence = SKAction.sequence([moveToM,wait,shrinkAndFade,remove])
				let eCopy = eLabel.copy() as! SKLabelNode
				
				self.addChild(eCopy)
				eCopy.run(eSequence)
				let moveMPos = CGPoint(x: (self.size.width/2)-70, y: mLabel.position.y)
				let moveM = SKAction.move(to: moveMPos, duration: 0.8)
				moveM.timingMode = .easeOut
				let MSeq = SKAction.sequence([moveM,wait,shrinkAndFade,grow,moveToCenter])
				mLabel.run(MSeq)
				let moveModPos = CGPoint(x: self.size.width/2, y: mLabel.position.y)
				let moveMod = SKAction.move(to: moveModPos, duration: 0.8)
				moveMod.timingMode = .easeOut
				let modSequence = SKAction.sequence([moveMod,wait,shrinkAndFade,remove])
				let modCopy = modLabel.copy() as! SKLabelNode
				
				self.addChild(modCopy)
				modCopy.run(modSequence)
				let moveNPos = CGPoint(x: (self.size.width/2)+60, y: mLabel.position.y)
				let moveN = SKAction.move(to: moveNPos, duration: 0.8)
				moveN.timingMode = .easeOut
				let Nseq = SKAction.sequence([moveN,wait,shrinkAndFade,remove])
				let nCopy = nLabel.copy() as! SKLabelNode
				self.addChild(nCopy)
				nCopy.run(Nseq)
				
				// hide the original labels to give illusion of movement
				eLabel.alpha = 0
				modLabel.alpha = 0
				nLabel.alpha = 0
				
				
				let waitC = SKAction.wait(forDuration: 2.2)
				let fade = SKAction.fadeIn(withDuration: 0.8)
				fade.timingMode = .easeIn
				let cSeq = SKAction.sequence([waitC,fade])
				cLabel.run(cSeq)
				eLabel.run(cSeq)
				modLabel.run(cSeq)
				nLabel.run(cSeq)
				
				let waitUntilEnd = SKAction.wait(forDuration: 2.3)
				let morphAction = SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in
					self.paperScene.morphToCrypto(duration: 0.8)
				})
				let morphSeq = SKAction.sequence([waitUntilEnd,morphAction])
				self.run(morphSeq)
				
			case .encrypted:
				paperScene.pulsePaper()
			}
		}
		else if (firstBody.categoryBitMask == PhysicsCategory.privateKeyA && secondBody.categoryBitMask == PhysicsCategory.box) {
			switch (paperScene.paperState) {
			case .unencrypted:
				
				paperScene.pulsePaper()
			case .encrypted:
				self.paperScene.paperState = .unencrypted
				
				let wait = SKAction.wait(forDuration: 1.5)
				let remove = SKAction.removeFromParent()
				let shrink = SKAction.scale(to: 0.6, duration: 0.4)
				shrink.timingMode = .easeIn
				let grow = SKAction.scale(to: 1, duration: 0)
				let fadeOut = SKAction.fadeOut(withDuration: 0.4)
				let centerPosition = CGPoint(x: self.size.width/2, y: cLabel.position.y)
				let moveToCenter = SKAction.move(to: centerPosition, duration: 0)
				let animateToCenter = SKAction.move(to: centerPosition, duration: 0.4)
				
				let shrinkAndFade = SKAction.group([shrink,fadeOut,animateToCenter])
				
				let position = CGPoint(x: (self.size.width/2)-45, y: cLabel.position.y+25)
				let moveToM = SKAction.move(to: position, duration: 0.8)
				moveToM.timingMode = .easeOut
				let eSequence = SKAction.sequence([moveToM,wait,shrinkAndFade,remove])
				let eCopy = dLabel.copy() as! SKLabelNode
				
				self.addChild(eCopy)
				eCopy.run(eSequence)
				let moveMPos = CGPoint(x: (self.size.width/2)-70, y: cLabel.position.y)
				let moveM = SKAction.move(to: moveMPos, duration: 0.8)
				moveM.timingMode = .easeOut
				let MSeq = SKAction.sequence([moveM,wait,shrinkAndFade,grow,moveToCenter])
				cLabel.run(MSeq)
				let moveModPos = CGPoint(x: self.size.width/2, y: cLabel.position.y)
				let moveMod = SKAction.move(to: moveModPos, duration: 0.8)
				moveMod.timingMode = .easeOut
				let modSequence = SKAction.sequence([moveMod,wait,shrinkAndFade,remove])
				let modCopy = modLabel.copy() as! SKLabelNode
				
				self.addChild(modCopy)
				modCopy.run(modSequence)
				let moveNPos = CGPoint(x: (self.size.width/2)+60, y: cLabel.position.y)
				let moveN = SKAction.move(to: moveNPos, duration: 0.8)
				moveN.timingMode = .easeOut
				let Nseq = SKAction.sequence([moveN,wait,shrinkAndFade,remove])
				let nCopy = nLabel.copy() as! SKLabelNode
				self.addChild(nCopy)
				nCopy.run(Nseq)
				
				// hide the original labels to give illusion of movement
				dLabel.alpha = 0
				modLabel.alpha = 0
				nLabel.alpha = 0
				
				
				let waitC = SKAction.wait(forDuration: 2.2)
				let fade = SKAction.fadeIn(withDuration: 0.8)
				fade.timingMode = .easeIn
				let cSeq = SKAction.sequence([waitC,fade])
				mLabel.run(cSeq)
				dLabel.run(cSeq)
				modLabel.run(cSeq)
				nLabel.run(cSeq)
				
				let waitUntilEnd = SKAction.wait(forDuration: 2.3)
				let morphAction = SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in
					self.paperScene.morphToPaper(duration: 0.8)
				})
				let morphSeq = SKAction.sequence([waitUntilEnd,morphAction])
				self.run(morphSeq)
				
			}
		}
	}
	
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
	
	override public func update(_ currentTime: TimeInterval) {
		// Called before each frame is rendered
		if let fingerPos = currentFingerPosition {
			self.publicKeyNode.updatePositionIfNeeded(to: fingerPos)
			self.privateKeyNode.updatePositionIfNeeded(to: fingerPos)
		}
		if let t = eLabel {
			let point = CGPoint(x: publicKeyNode.position.x, y: publicKeyNode.position.y+30)
			let moveToPosition = SKAction.move(to: point, duration: 0.02)
			t.run(moveToPosition)
		}
		if let t = dLabel {
			let point = CGPoint(x: privateKeyNode.position.x, y: privateKeyNode.position.y+30)
			let moveToPosition = SKAction.move(to: point, duration: 0.02)
			t.run(moveToPosition)
		}
	}
	
}

