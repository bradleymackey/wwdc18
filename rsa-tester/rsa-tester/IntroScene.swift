
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
    
    // MARK: Constants
    public static let mathsAnimationMoveTime:TimeInterval = 0.8
    public static let mathsAnimationPauseTime:TimeInterval = 1.5
    public static let mathsAnimationShrinkFadeTime:TimeInterval = 0.6
    
    public static let mathsEnabled = true
	
	// MARK: Sprites
	var publicKeyNode:KeySprite!
	var privateKeyNode:KeySprite!
	var messageSceneNode:Message3DNode!
	
	// MARK: 3D Scene
	lazy var paperScene = Message3DScene(message: "Here's to the crazy ones. The misfits. The troublemakers. The round pegs in the square holes.")
	
	// MARK: Tracking Variables
	var currentFingerPosition:CGPoint?
    var currentlyAnimating = false
	
	// MARK: Maths labels
	var mLabel:SKLabelNode!
	var nLabel:SKLabelNode!
	var eLabel:SKLabelNode!
	var dLabel:SKLabelNode!
	var modLabel:SKLabelNode!
	var cLabel:SKLabelNode!
    
    let encryptor = RSAEncryptor(p: 3, q: 17)
	
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
        
        // only add the maths labels if maths is enabled
        guard IntroScene.mathsEnabled else { return }
        self.createMathsLabels(message: 7)
	}
    
    private func createMathsLabels(message:Int) {
        // the encryptor
        let encryptedMessage = encryptor.encryption(forMessage: message)
        // the message as number
        mLabel = IntroScene.mathsLabel(text: "\(message)", fontSize: 45, color: .black, bold: true)
        mLabel.position =  CGPoint(x: self.size.width/2, y: 2.75*self.size.height/4)
        self.addChild(mLabel)
        // the public modulus
        nLabel = IntroScene.mathsLabel(text: "\(encryptor.N)", fontSize: 45, color: .gray, bold: false)
        nLabel.position =  CGPoint(x: self.size.width-30, y: self.size.height-30)
        self.addChild(nLabel)
        // the public exponent
        eLabel = IntroScene.mathsLabel(text: "\(encryptor.e)", fontSize: 30, color: .black, bold: false)
        eLabel.position =  CGPoint(x: publicKeyNode.position.x, y: publicKeyNode.position.y+30)
        self.addChild(eLabel)
        // private exponent
        dLabel = IntroScene.mathsLabel(text: "\(encryptor.d)", fontSize: 30, color: .black, bold: false)
        dLabel.position =  CGPoint(x: privateKeyNode.position.x, y: privateKeyNode.position.y+30)
        self.addChild(dLabel)
        // modulus label
        modLabel = IntroScene.mathsLabel(text: "mod", fontSize: 30, color: .gray, bold: false)
        modLabel.position =  CGPoint(x: self.nLabel.position.x-60, y: self.nLabel.position.y)
        self.addChild(modLabel)
        // the encrypted text as number
        cLabel = IntroScene.mathsLabel(text: "\(encryptedMessage)", fontSize: 45, color: .black, bold: true)
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
			self.publicKeyContact()
		}
		else if (firstBody.categoryBitMask == PhysicsCategory.privateKeyA && secondBody.categoryBitMask == PhysicsCategory.box) {
			self.privateKeyContact()
		}
	}
    
    private func publicKeyContact() {
        // do nothing if we are currently animating
        if currentlyAnimating { return }
        currentlyAnimating = true
        switch (paperScene.paperState) {
        case .unencrypted:
            // mark the new state
            self.paperScene.paperState = .encrypted
            // perform the maths animation if enabled, otherwise just morph
            guard IntroScene.mathsEnabled else {
                self.paperScene.morphToCrypto(duration: IntroScene.mathsAnimationMoveTime)
                // inform that we are no longer animating after the animation when we are not using maths animations
                DispatchQueue.main.asyncAfter(deadline: .now() + IntroScene.mathsAnimationMoveTime) {
                    self.currentlyAnimating = false
                }
                return
            }
            self.performMathsAnimation(transformToState: .encrypted)
        case .encrypted:
            let wait = SKAction.wait(forDuration: 0.4)
            let questionMark = SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in
                self.paperScene.morphToQuestionMark(duration: 0.4)
            })
            let backToCrypto = SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in
                self.paperScene.morphToCrypto(duration: 0.4)
            })
            let notAnimating = SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in
                self.currentlyAnimating = false
            })
            let invalidContactSequence = SKAction.sequence([questionMark,wait,backToCrypto,wait,notAnimating])
            self.messageSceneNode.run(invalidContactSequence)
        }
    }
    
    private func privateKeyContact() {
        // do nothing if we are currently animating
        if currentlyAnimating { return }
        currentlyAnimating = true
        switch (paperScene.paperState) {
        case .unencrypted:
            let wait = SKAction.wait(forDuration: 0.4)
            let questionMark = SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in
                self.paperScene.morphToQuestionMark(duration: 0.4)
            })
            let backToPaper = SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in
                self.paperScene.morphToPaper(duration: 0.4)
            })
            let notAnimating = SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in
                self.currentlyAnimating = false
            })
            let invalidContactSequence = SKAction.sequence([questionMark,wait,backToPaper,wait,notAnimating])
            self.messageSceneNode.run(invalidContactSequence)
        case .encrypted:
            // mark the new state
            self.paperScene.paperState = .unencrypted
            // perform the maths animation is enabled, otherwise just morph
            guard IntroScene.mathsEnabled else {
                self.paperScene.morphToPaper(duration: IntroScene.mathsAnimationMoveTime)
                // inform that we are no longer animating after the animation when we are not using maths animations
                DispatchQueue.main.asyncAfter(deadline: .now() + IntroScene.mathsAnimationMoveTime) {
                    self.currentlyAnimating = false
                }
                return
            }
            self.performMathsAnimation(transformToState: .unencrypted)
        }
    }
    
    /// animates the maths labels when the key is brought to the message label/crypto box
    private func performMathsAnimation(transformToState state:Message3DScene.PaperState) {
        
        let encrypting = state == .encrypted
        let keyLabel:SKLabelNode = encrypting ? eLabel : dLabel
        let oldMessageLabel:SKLabelNode = encrypting ? mLabel : cLabel
        let newMessageLabel:SKLabelNode = encrypting ? cLabel : mLabel
        
        let centerPosition = CGPoint(x: self.size.width/2, y: oldMessageLabel.position.y)
        // animate key label
        let keyLabelNewPosition = CGPoint(x: (self.size.width/2)-43, y: oldMessageLabel.position.y+28)
        self.moveShrinkFadeRemoveCopy(node: keyLabel, movePosition: keyLabelNewPosition, shrinkPosition: centerPosition)
        // animate mod label
        let newModPosition = CGPoint(x: self.size.width/2, y: oldMessageLabel.position.y)
        self.moveShrinkFadeRemoveCopy(node: modLabel, movePosition: newModPosition, shrinkPosition: centerPosition)
        // animate N
        let newNPosition = CGPoint(x: (self.size.width/2)+65, y: oldMessageLabel.position.y)
        self.moveShrinkFadeRemoveCopy(node: nLabel, movePosition: newNPosition, shrinkPosition: centerPosition)
        // animate old message label
        let oldMessageEquationPosition = CGPoint(x: (self.size.width/2)-75, y: oldMessageLabel.position.y)
        let moveOldMessageAnimation = SKAction.move(to: oldMessageEquationPosition, duration: IntroScene.mathsAnimationMoveTime)
        moveOldMessageAnimation.timingMode = .easeOut
        let pauseShrinkFadeOld = IntroScene.pauseShrinkFade(toPosition: centerPosition)
        let grow = SKAction.scale(to: 1, duration: 0)
        let moveToCenter = SKAction.move(to: centerPosition, duration: 0)
        let oldMessageSequence = SKAction.sequence([moveOldMessageAnimation,pauseShrinkFadeOld,grow,moveToCenter])
        oldMessageLabel.run(oldMessageSequence)
        
        // animate new message label and other labels back in
        let waitNewLabel = SKAction.wait(forDuration: IntroScene.mathsAnimationPauseTime + 1.0)
        let fadeBackIn = SKAction.fadeIn(withDuration: IntroScene.mathsAnimationMoveTime)
        fadeBackIn.timingMode = .easeIn
        let fadeBackSequence = SKAction.sequence([waitNewLabel,fadeBackIn])
        newMessageLabel.run(fadeBackSequence)
        keyLabel.run(fadeBackSequence)
        modLabel.run(fadeBackSequence)
        nLabel.run(fadeBackSequence)
        
        let waitUntilEnd = SKAction.wait(forDuration: IntroScene.mathsAnimationMoveTime + 1.8)
        let morphAction = SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in
            encrypting ? self.paperScene.morphToCrypto(duration: IntroScene.mathsAnimationMoveTime) : self.paperScene.morphToPaper(duration: IntroScene.mathsAnimationMoveTime)
        })
        let notAnimating = SKAction.customAction(withDuration: 0, actionBlock: { (node, time) in
            self.currentlyAnimating = false
        })
        let morphSeq = SKAction.sequence([waitUntilEnd,morphAction,notAnimating])
        self.run(morphSeq)
    }
    
    private func moveShrinkFadeRemoveCopy(node:SKNode, movePosition:CGPoint, shrinkPosition:CGPoint) {
        let moveAnimation = SKAction.move(to: movePosition, duration: IntroScene.mathsAnimationMoveTime)
        moveAnimation.timingMode = .easeOut
        let pauseShrinkFadeAction = IntroScene.pauseShrinkFade(toPosition: shrinkPosition)
        let removeNode = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveAnimation,pauseShrinkFadeAction,removeNode])
        let nodeCopy = node.copy() as! SKNode
        self.addChild(nodeCopy)
        node.alpha = 0
        nodeCopy.run(sequence)
    }
    
    private class func pauseShrinkFade(toPosition newPosition:CGPoint) -> SKAction {
        let pauseTime = SKAction.wait(forDuration: IntroScene.mathsAnimationPauseTime)
        let shrinkAnimation = SKAction.scale(to: 0.6, duration: IntroScene.mathsAnimationShrinkFadeTime)
        shrinkAnimation.timingMode = .easeIn
        let fadeAnimation = SKAction.fadeOut(withDuration: IntroScene.mathsAnimationShrinkFadeTime/1.2)
        fadeAnimation.timingMode = .easeIn
        let animateToPosition = SKAction.move(to: newPosition, duration: IntroScene.mathsAnimationShrinkFadeTime)
        animateToPosition.timingMode = .easeIn
        let group = SKAction.group([shrinkAnimation, fadeAnimation, animateToPosition])
        return SKAction.sequence([pauseTime,group])
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
		if let eLabel = eLabel, let publicKey = publicKeyNode {
			self.move(node: eLabel, above: publicKey)
		}
        if let dLabel = dLabel, let privateKey = privateKeyNode {
			self.move(node: dLabel, above: privateKey)
		}
	}
    
    private func move(node:SKNode, above mainNode:SKNode) {
        let point = CGPoint(x: mainNode.position.x, y: mainNode.position.y+30)
        let moveToPosition = SKAction.move(to: point, duration: 0.02)
        node.run(moveToPosition)
    }
	
}

