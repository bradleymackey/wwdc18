//
//  IntroScene.swift
//  nothing
//
//  Created by Bradley Mackey on 18/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

/// used for delegating the display of information about labels when tapped
public protocol IntroSceneInformationDelegate: class {
	func presentInformationPopup(title:String, message:String)
}

/// the initial scene used to introduce the user to RSA
public final class IntroScene: RSAScene {
    
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
	
	private lazy var publicKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.publicColor, owner: .alice, type: .pub)
		keySprite.name = "publicKeyNode"
		keySprite.position = CGPoint(x: self.size.width/4, y: self.size.height/4)
		return keySprite
	}()
	
	private lazy var privateKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.privateColor, owner: .alice, type: .priv)
		keySprite.name = "privateKeyNode"
		keySprite.position = CGPoint(x: 3*self.size.width/4, y: self.size.height/4)
		return keySprite
	}()
	
	private lazy var messageSceneNode:Message3DNode = {
		let sceneSize = CGSize(width: 220, height: 220)
		let sceneNode = Message3DNode(viewportSize: sceneSize, messageScene: IntroScene.paperScene)
		sceneNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
		sceneNode.name = "3dnode"
		return sceneNode
	}()
	
	// MARK: Maths labels
	
	/// the message
	private lazy var mLabel:SKLabelNode = {
		let labelText = IntroScene.useRealValues ? "\(IntroScene.message)" : "M"
		let label = RSAScene.mathsLabel(text: labelText, fontSize: 60, color: .black, bold: true)
		label.position =  CGPoint(x: self.size.width/2, y: 2.75*self.size.height/4)
		label.name = "mLabel"
		return label
	}()
	
	/// the public modulus
	private lazy var nLabel:SKLabelNode = {
		let labelText = IntroScene.useRealValues ? "\(IntroScene.encryptor.N)" : "N"
		let label = RSAScene.mathsLabel(text: labelText, fontSize: 44, color: IntroScene.publicColor, bold: false)
		label.position =  CGPoint(x: self.size.width-65, y: self.size.height-60)
		label.name = "nLabel"
		return label
	}()
	
	/// the public exponent
	private lazy var eLabel:SKLabelNode = {
		let labelText = IntroScene.useRealValues ? "\(IntroScene.encryptor.e)" : "e"
		let label = RSAScene.mathsLabel(text: labelText, fontSize: 30, color: IntroScene.publicColor, bold: true)
		label.position =  CGPoint(x: publicKeyNode.position.x, y: publicKeyNode.position.y+45)
		label.name = "eLabel"
		return label
	}()
	
	/// the private exponent
	private lazy var dLabel:SKLabelNode = {
		let labelText = IntroScene.useRealValues ? "\(IntroScene.encryptor.d)" : "d"
		let label = RSAScene.mathsLabel(text: labelText, fontSize: 30, color: IntroScene.privateColor, bold: true)
		label.position =  CGPoint(x: privateKeyNode.position.x, y: privateKeyNode.position.y+45)
		label.name = "dLabel"
		return label
	}()
	
	/// the 'mod' label that is just for visual completeness
	private lazy var modLabel:SKLabelNode = {
		let label = RSAScene.mathsLabel(text: "mod", fontSize: 40, color: IntroScene.publicColor, bold: false)
		label.position =  CGPoint(x: self.nLabel.position.x-90, y: self.nLabel.position.y)
		label.name = "modLabel"
		return label
	}()
	
	/// the encrpyted message label
	private lazy var cLabel:SKLabelNode = {
		// encrypt the message using the encryptor
		let encryptedMessage = IntroScene.encryptor.encryption(forMessage: IntroScene.message)
		let labelText = IntroScene.useRealValues ? "\(encryptedMessage)" : "C"
		let label = RSAScene.mathsLabel(text: labelText, fontSize: 60, color: .black, bold: true)
		label.position = CGPoint(x: self.size.width/2, y: 2.75*self.size.height/4)
		label.name = "cLabel"
		label.alpha = 0
		return label
	}()
	
	private lazy var pLabel:SKLabelNode = {
		let label = RSAScene.mathsLabel(text: "p=\(IntroScene.encryptor.p)", fontSize: 30, color: IntroScene.privateColor, bold: false)
		label.position = CGPoint(x: 25, y: self.size.height-45)
		label.name = "pLabel"
		// align left because it makes the most sense
		label.horizontalAlignmentMode = .left
		return label
	}()
	
	private lazy var qLabel:SKLabelNode = {
		let label = RSAScene.mathsLabel(text: "q=\(IntroScene.encryptor.q)", fontSize: 30, color: IntroScene.privateColor, bold: false)
		label.position = CGPoint(x: 25, y: self.size.height-85)
		label.name = "qLabel"
		// align left because it makes the most sense
		label.horizontalAlignmentMode = .left
		return label
	}()
	
	// MARK: Tracking Variables
	var currentlyAnimating = false
	var currentlySelectedLabel:String?
	
	// MARK: - Methods
	
	// MARK: Setup
	
	override public func sceneDidLoad() {
		super.sceneDidLoad()
		self.backgroundColor = .white
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
	
	// MARK: Methods
	
	override public func touchDown(atPoint point: CGPoint) {
		// call the implementation in RSAScene
		super.touchDown(atPoint: point)
		// get the node that we have just touched
		let node = self.atPoint(point)
		// ensure that the node has a name
		guard let nodeName = node.name else { return }
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
	
	override public func touchMoved(toPoint point: CGPoint) {
		// call the implementation in RSAScene
		super.touchMoved(toPoint: point)
		// update objects if we need to
		self.messageSceneNode.updateRotationIfRotating(newPoint: point)
	}
	
	override public func touchUp(atPoint point: CGPoint) {
		// call the implementation in RSAScene
		super.touchUp(atPoint: point)
		if let labelSelected = currentlySelectedLabel {
			defer {
				currentlySelectedLabel = nil
			}
			// ensure that the touch up was also inside of the label we started to touch
			let node = self.atPoint(point)
			guard let nodeName = node.name else { return }
			guard nodeName == labelSelected else { return }
			self.showInfoPanel(forLabel: labelSelected)
		}
		// stop moving keys if they were being moved
		self.privateKeyNode.stopMoving(at: point)
		self.publicKeyNode.stopMoving(at: point)
		// stop rotating the message if it was being rotated
		self.messageSceneNode.finishedRotating()
	}
	
	override public func bodyContact(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
		super.bodyContact(firstBody: firstBody, secondBody: secondBody)
        // we only care about contact where the second item is the box
        guard secondBody.categoryBitMask == PhysicsCategory.box else { return }
        // determine the first body
        switch firstBody.categoryBitMask {
        case PhysicsCategory.publicKeyA:
            self.publicKeyContact()
        case PhysicsCategory.privateKeyA:
            self.privateKeyContact()
        default:
            return
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
        let keyLabelNewPosition = CGPoint(x: (self.size.width/2)-48, y: oldMessageLabel.position.y+34)
        self.moveShrinkFadeRemoveCopy(node: keyLabel, movePosition: keyLabelNewPosition, shrinkPosition: centerPosition)
        // animate mod label
        let newModPosition = CGPoint(x: self.size.width/2, y: oldMessageLabel.position.y)
        self.moveShrinkFadeRemoveCopy(node: modLabel, movePosition: newModPosition, shrinkPosition: centerPosition)
        // animate N
        let newNPosition = CGPoint(x: (self.size.width/2)+90, y: oldMessageLabel.position.y)
        self.moveShrinkFadeRemoveCopy(node: nLabel, movePosition: newNPosition, shrinkPosition: centerPosition)
        // animate old message label
		// move the label more if there are 2 characters being displayed
		let amountToMove:CGFloat = oldMessageLabel.text!.count == 1 ? 90 : 100
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
	
	override public func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // make sure that the maths labels are above the keys if needed
        if IntroScene.mathsEnabled {
            self.move(node: eLabel, above: publicKeyNode, by: 45.0)
            self.move(node: dLabel, above: privateKeyNode, by: 45.0)
        }
		// update finger position or exit
        guard let point = currentFingerPosition else { return }
        // ignore movement if position is outside scene
        let margin:CGFloat = 10
        if point.x < margin || point.x > self.size.width - margin || point.y < margin || point.y > self.size.height - margin {
            // stop moving keys if the touch is outside the margin
            self.privateKeyNode.stopMoving(at: point)
            self.publicKeyNode.stopMoving(at: point)
        } else {
            self.publicKeyNode.updatePositionIfNeeded(to: point)
            self.privateKeyNode.updatePositionIfNeeded(to: point)
        }
	}
	
	private func showInfoPanel(forLabel label:String) {
		switch label {
		case "mLabel":
			self.informationDelegate?.presentInformationPopup(title: "Message", message: "This is the message that we will encrypt, in the format of a number, so we can do the required maths operations. We can encrypt the message by using the Public Modulus and Public Exponent.")
		case "cLabel":
			self.informationDelegate?.presentInformationPopup(title: "Cipher Text", message: "This is the encrypted message. We can only convert this back to the original message with the private key (the Public Modulus and Private Exponent).")
		case "modLabel":
			self.informationDelegate?.presentInformationPopup(title: "Modulo Operator", message: "This is the operator that is used to calculate the remainder after dividing some number by another number.")
		case "nLabel":
			self.informationDelegate?.presentInformationPopup(title: "Public Modulus", message: "This is the number that makes up part of the public key and the private key. It is calculated by multiplying p and q, and is used when we encrypt the message and also when we decrypt the cipher text.")
		case "eLabel":
			self.informationDelegate?.presentInformationPopup(title: "Public Exponent", message: "This is the one of the parts of the public key. In order to calculate the cipher text, the message is raised to the power of this number and then we calculate modulo N of this number.")
		case "dLabel":
			self.informationDelegate?.presentInformationPopup(title: "Private Exponent", message: "This is the one of the parts of the private key. In order to calculate the original message, the cipher text is raised to the power of this number and then we calculate modulo N of this number.")
		case "pLabel":
			self.informationDelegate?.presentInformationPopup(title: "Prime p", message: "This is one of the prime numbers used to calculate N (p*q), and (p-1) is used in calculating (p-1)(q-1), which constrains the values that e can be.")
		case "qLabel":
			self.informationDelegate?.presentInformationPopup(title: "Prime q", message: "This is one of the prime numbers used to calculate N (p*q), and (q-1) is used in calculating (p-1)(q-1), which constrains the values that e can be.")
		default:
			return
		}
	}
	
}
