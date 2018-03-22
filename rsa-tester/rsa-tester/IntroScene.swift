
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

/// used for delegating the display of information about labels when tapped
public protocol IntroSceneInformationDelegate: class {
	func presentInformationPopup(title:String, message:String)
}

/// the initial scene used to introduce the user to RSA
final public class IntroScene: SKScene, SKPhysicsContactDelegate {
    
    // MARK: Constants
	
    public static let mathsAnimationMoveTime:TimeInterval = 0.8
    public static let mathsAnimationPauseTime:TimeInterval = 1.5
    public static let mathsAnimationShrinkFadeTime:TimeInterval = 0.6
	public static let invalidPulseTime:TimeInterval = 0.4
    
    public static var mathsEnabled = true
	public static var useRealValues = true
	
	public static var message = 16
	
	public static var publicColor = #colorLiteral(red: 0.02509527327, green: 0.781170527, blue: 2.601820516e-16, alpha: 1)
	public static var privateColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
	
	// MARK: Delegate
	/// for delegating an information message for a UIView to present
	public weak var informationDelegate:IntroSceneInformationDelegate?
	
	// MARK: 3D Scene
	public static var paperScene = Message3DScene(message: "Here's to the crazy ones. The misfits. The round pegs in the square holes. Think different.")
	
	// MARK: Encryption
	/// the encryption engine
	public static var encryptor = RSAEncryptor(p: 17, q: 17)
	
	// MARK: Sprites
	
	/// simply loads the key texture so we don't have to reload it for each key
	private static let keyTexture = KeySprite.textureForKey()
	
	private lazy var publicKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: IntroScene.keyTexture, color: IntroScene.publicColor, owner: .alice, type: .pub)
		keySprite.name = "publicKeyNode"
		keySprite.position = CGPoint(x: self.size.width/4, y: self.size.height/4)
		return keySprite
	}()
	
	private lazy var privateKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: IntroScene.keyTexture, color: IntroScene.privateColor, owner: .alice, type: .priv)
		keySprite.name = "privateKeyNode"
		keySprite.position = CGPoint(x: 3*self.size.width/4, y: self.size.height/4)
		return keySprite
	}()
	
	private lazy var messageSceneNode:Message3DNode = {
		let sceneSize = CGSize(width: 150, height: 150)
		let sceneNode = Message3DNode(viewportSize: sceneSize, messageScene: IntroScene.paperScene)
		sceneNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
		sceneNode.name = "3dnode"
		return sceneNode
	}()
	
	// MARK: Maths labels
	
	/// the message
	private lazy var mLabel:SKLabelNode = {
		let labelText = IntroScene.useRealValues ? "\(IntroScene.message)" : "M"
		let label = IntroScene.mathsLabel(text: labelText, fontSize: 40, color: .black, bold: true)
		label.position =  CGPoint(x: self.size.width/2, y: 2.75*self.size.height/4)
		label.name = "mLabel"
		return label
	}()
	
	/// the public modulus
	private lazy var nLabel:SKLabelNode = {
		let labelText = IntroScene.useRealValues ? "\(IntroScene.encryptor.N)" : "N"
		let label = IntroScene.mathsLabel(text: labelText, fontSize: 32, color: IntroScene.publicColor, bold: false)
		label.position =  CGPoint(x: self.size.width-35, y: self.size.height-30)
		label.name = "nLabel"
		return label
	}()
	
	/// the public exponent
	private lazy var eLabel:SKLabelNode = {
		let labelText = IntroScene.useRealValues ? "\(IntroScene.encryptor.e)" : "e"
		let label = IntroScene.mathsLabel(text: labelText, fontSize: 25, color: IntroScene.publicColor, bold: false)
		label.position =  CGPoint(x: publicKeyNode.position.x, y: publicKeyNode.position.y+40)
		label.name = "eLabel"
		return label
	}()
	
	/// the private exponent
	private lazy var dLabel:SKLabelNode = {
		let labelText = IntroScene.useRealValues ? "\(IntroScene.encryptor.d)" : "d"
		let label = IntroScene.mathsLabel(text: labelText, fontSize: 25, color: IntroScene.privateColor, bold: false)
		label.position =  CGPoint(x: privateKeyNode.position.x, y: privateKeyNode.position.y+40)
		label.name = "dLabel"
		return label
	}()
	
	/// the 'mod' label that is just for visual completeness
	private lazy var modLabel:SKLabelNode = {
		let label = IntroScene.mathsLabel(text: "mod", fontSize: 28, color: IntroScene.publicColor, bold: false)
		label.position =  CGPoint(x: self.nLabel.position.x-60, y: self.nLabel.position.y)
		label.name = "modLabel"
		return label
	}()
	
	/// the encrpyted message label
	private lazy var cLabel:SKLabelNode = {
		// encrypt the message using the encryptor
		let encryptedMessage = IntroScene.encryptor.encryption(forMessage: IntroScene.message)
		let labelText = IntroScene.useRealValues ? "\(encryptedMessage)" : "C"
		let label = IntroScene.mathsLabel(text: labelText, fontSize: 40, color: .black, bold: true)
		label.position = CGPoint(x: self.size.width/2, y: 2.75*self.size.height/4)
		label.name = "cLabel"
		label.alpha = 0
		return label
	}()
	
	private lazy var pLabel:SKLabelNode = {
		let label = IntroScene.mathsLabel(text: "p=\(IntroScene.encryptor.p)", fontSize: 22, color: IntroScene.privateColor, bold: false)
		label.position = CGPoint(x: 10, y: self.size.height-25)
		label.name = "pLabel"
		// align left because it makes the most sense
		label.horizontalAlignmentMode = .left
		return label
	}()
	
	private lazy var qLabel:SKLabelNode = {
		let label = IntroScene.mathsLabel(text: "q=\(IntroScene.encryptor.q)", fontSize: 22, color: IntroScene.privateColor, bold: false)
		label.position = CGPoint(x: 10, y: self.size.height-50)
		label.name = "qLabel"
		// align left because it makes the most sense
		label.horizontalAlignmentMode = .left
		return label
	}()
	
	// MARK: Tracking Variables
	var currentFingerPosition:CGPoint?
	var currentlyAnimating = false
	var currentlySelectedLabel:String?
	
	// MARK: - Methods
	
	// MARK: Setup
	
	override public func sceneDidLoad() {
		super.sceneDidLoad()
		self.backgroundColor = .white
		// setup the physics for the world
		self.setupWorldPhysics()
		// create the paper and the scene node
		self.addMessageSceneNode()
		// create the key sprites
		self.addKeySprites()
		// only add the maths labels if maths is enabled
		self.addMathsLabelsIfNeeded()
	}

	private func addMessageSceneNode() {
		self.addChild(messageSceneNode)
	}
	
	private func addKeySprites() {
		self.addChild(publicKeyNode)
		self.addChild(privateKeyNode)
	}
	
	private func addMathsLabelsIfNeeded() {
		guard IntroScene.mathsEnabled else { return }
		// add the maths labels to the scene
		[mLabel, nLabel, eLabel, dLabel, modLabel, cLabel].forEach {
			self.addChild($0)
		}
		// add the p and q labels if we are displaying real values
		guard IntroScene.useRealValues else { return }
		[pLabel, qLabel].forEach {
			self.addChild($0)
		}
	}
	
	/// the basic structure of a maths labels, which all labels share
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
		self.physicsBody = IntroScene.worldPhysicsBody(frame: self.frame.insetBy(dx: 20, dy: 20))
	}
	
	private class func worldPhysicsBody(frame:CGRect) -> SKPhysicsBody {
		let body = SKPhysicsBody(edgeLoopFrom: frame)
		body.affectedByGravity = false
		body.categoryBitMask = PhysicsCategory.boundry
		body.contactTestBitMask = PhysicsCategory.none
		body.collisionBitMask = PhysicsCategory.all
		return body
	}
	
	// MARK: Methods
	
	func touchDown(atPoint point: CGPoint) {
		currentFingerPosition = point
		let node = self.atPoint(point)
		// ensure that the node has a name
		guard let nodeName = node.name else {
			return
		}
		// different behaviour if this node is a label
		guard !nodeName.contains("Label") else {
			self.currentlySelectedLabel = nodeName
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
		if let labelSelected = currentlySelectedLabel {
			defer {
				currentlySelectedLabel = nil
			}
			self.showInfoPanel(forLabel: labelSelected)
		}
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
        switch (IntroScene.paperScene.paperState) {
        case .unencrypted:
            // mark the new state
            IntroScene.paperScene.paperState = .encrypted
            // perform the maths animation if enabled, otherwise just morph
            guard IntroScene.mathsEnabled else {
                IntroScene.paperScene.morphToCrypto(duration: IntroScene.mathsAnimationMoveTime)
                // inform that we are no longer animating after the animation when we are not using maths animations
                DispatchQueue.main.asyncAfter(deadline: .now() + IntroScene.mathsAnimationMoveTime) {
                    self.currentlyAnimating = false
                }
                return
            }
            self.performMathsAnimation(transformToState: .encrypted)
        case .encrypted:
			// do the question mark animation
            self.invalidContactAnimation(forState: .encrypted)
        }
    }
    
    private func privateKeyContact() {
        // do nothing if we are currently animating
        if currentlyAnimating { return }
        currentlyAnimating = true
        switch (IntroScene.paperScene.paperState) {
        case .unencrypted:
			// do the question mark animation
			self.invalidContactAnimation(forState: .unencrypted)
        case .encrypted:
            // mark the new state
            IntroScene.paperScene.paperState = .unencrypted
            // perform the maths animation is enabled, otherwise just morph
            guard IntroScene.mathsEnabled else {
                IntroScene.paperScene.morphToPaper(duration: IntroScene.mathsAnimationMoveTime)
                // inform that we are no longer animating after the animation when we are not using maths animations
                DispatchQueue.main.asyncAfter(deadline: .now() + IntroScene.mathsAnimationMoveTime) {
                    self.currentlyAnimating = false
                }
                return
            }
            self.performMathsAnimation(transformToState: .unencrypted)
        }
    }
	
	/// the animation that should run when the incorrect key is brought to the box
	private func invalidContactAnimation(forState state:Message3DScene.PaperState) {
		let wait = SKAction.wait(forDuration: IntroScene.invalidPulseTime)
		let questionMark = SKAction.customAction(withDuration: 0) { _, _ in
			IntroScene.paperScene.morphToQuestionMark(duration: IntroScene.invalidPulseTime)
		}
		let backToPaper = SKAction.customAction(withDuration: 0) { _, _ in
			state == .encrypted ? IntroScene.paperScene.morphToCrypto(duration: IntroScene.invalidPulseTime) : IntroScene.paperScene.morphToPaper(duration: IntroScene.invalidPulseTime)
		}
		let notAnimating = SKAction.customAction(withDuration: 0) { _, _ in
			self.currentlyAnimating = false
		}
		let invalidContactSequence = SKAction.sequence([questionMark,wait,backToPaper,wait,notAnimating])
		self.messageSceneNode.run(invalidContactSequence)
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
		// move the label more if there are 2 characters being displayed
		let amountToMove:CGFloat = oldMessageLabel.text!.count == 1 ? 65 : 75
        let oldMessageEquationPosition = CGPoint(x: (self.size.width/2)-amountToMove, y: oldMessageLabel.position.y)
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
        let morphAction = SKAction.customAction(withDuration: 0) { _, _ in
            encrypting ? IntroScene.paperScene.morphToCrypto(duration: IntroScene.mathsAnimationMoveTime) : IntroScene.paperScene.morphToPaper(duration: IntroScene.mathsAnimationMoveTime)
        }
        let notAnimating = SKAction.customAction(withDuration: 0) { _, _ in
            self.currentlyAnimating = false
        }
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
		if let fingerPos = currentFingerPosition, fingerPos.x > 20, fingerPos.y > 20, fingerPos.x < self.frame.size.width-20, fingerPos.y < self.frame.size.height-20 {
			self.publicKeyNode.updatePositionIfNeeded(to: fingerPos)
			self.privateKeyNode.updatePositionIfNeeded(to: fingerPos)
		}
		// make sure that the maths labels are above the keys if needed
		if IntroScene.mathsEnabled {
			self.move(node: eLabel, above: publicKeyNode)
			self.move(node: dLabel, above: privateKeyNode)
		}
	}
    
    private func move(node:SKNode, above mainNode:SKNode) {
        let point = CGPoint(x: mainNode.position.x, y: mainNode.position.y+40)
        let moveToPosition = SKAction.move(to: point, duration: 0.01)
        node.run(moveToPosition)
    }
	
	private func showInfoPanel(forLabel label:String) {
		switch label {
		case "mLabel":
			self.informationDelegate?.presentInformationPopup(title: "Message", message: "This is the message that we will encrypt, in the format of a number, so we can do the required maths operations.")
		case "cLabel":
			self.informationDelegate?.presentInformationPopup(title: "Cipher Text", message: "This is the encrypted message. We can only convert this back to the original message with the private key.")
		case "modLabel":
			self.informationDelegate?.presentInformationPopup(title: "Modulo", message: "This is the operation that is performed blah blah.")
		case "nLabel":
			self.informationDelegate?.presentInformationPopup(title: "Public Modulus", message: "This is the number that is makes up part of the public key and the private key. It is calculated by multiplying p and q, and is used when we encrypt the message and decrypt the cipher text.")
		case "eLabel":
			self.informationDelegate?.presentInformationPopup(title: "Public Exponent", message: "This is the one of the parts of the public key. In order to calculate the cipher text, the message is raised to the power of this number and then we calculate modulo N of this number.")
		case "dLabel":
			self.informationDelegate?.presentInformationPopup(title: "Private Exponent", message: "This is the one of the parts of the private key. In order to calculate the original message, the cipher text is raised to the power of this number and then we calculate modulo N of this number.")
		case "pLabel":
			self.informationDelegate?.presentInformationPopup(title: "p", message: "This is one of the prime numbers used to calculate N, and (p-1) is one of the numbers that contrain the possible values that e can be.")
		case "qLabel":
			self.informationDelegate?.presentInformationPopup(title: "q", message: "This is one of the prime numbers used to calculate N, and (q-1) is one of the numbers that contrain the possible values that e can be.")
		default:
			return
		}
	}
	
}
