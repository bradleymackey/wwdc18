//
//  IntroScene.swift
//  nothing
//
//  Created by Bradley Mackey on 18/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

/// used for delegating the display of information about labels when tapped
public protocol IntroSceneInformationDelegate: class {
	func presentInformationPopup(title:String, message:String)
}

/// the initial scene used to introduce the user to RSA
public final class MathematicsScene: RSAScene {
    
    // MARK: Constants
	
    public static let mathsAnimationMoveTime:TimeInterval = 0.8
    public static let mathsAnimationPauseTime:TimeInterval = 1.5
    public static let mathsAnimationShrinkFadeTime:TimeInterval = 0.6
	public static let invalidPulseTime:TimeInterval = 0.4
    
    public static var mathsEnabled = false
	public static var useRealValues = true
	
	public static var publicColor = #colorLiteral(red: 0.02509527327, green: 0.781170527, blue: 2.601820516e-16, alpha: 1)
	public static var privateColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
	
	public static let initialTapSound = SKAction.playSoundFileNamed("click.caf", waitForCompletion: false)
    public static let popupSound = SKAction.playSoundFileNamed("popup.caf", waitForCompletion: false)
	public static let pickupKeySound = SKAction.playSoundFileNamed("pickup.caf", waitForCompletion: false)
	public static let dropKeySound = SKAction.playSoundFileNamed("drop.caf", waitForCompletion: false)
	
	// MARK: State
	
	// MARK: Delegate
	
	/// for delegating an information message for a UIView to present
	public weak var informationDelegate:IntroSceneInformationDelegate?
	
	// MARK: 3D Scene
	
	public static var paperScene = Message3DScene(message: "Here's to the crazy ones. The misfits. The round pegs in the square holes. Think different.")
	
	// MARK: Encryption
	
	/// the encryption engine
	public static var encryptor = RSAEncryptor(p: 17, q: 17, message: 14)
	
	// MARK: Sprites
	
	private lazy var publicKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: MathematicsScene.publicColor, owner: .alice, type: .`public`, size: 55)
		keySprite.name = "publicKeyNode"
		keySprite.position = CGPoint(x: self.size.width/4, y: self.size.height/4)
		keySprite.stateMachine = MathematicsScene.introKeyMachine(forKey: keySprite)
		return keySprite
	}()
	
	private lazy var privateKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: MathematicsScene.privateColor, owner: .alice, type: .`private`, size: 55)
		keySprite.name = "privateKeyNode"
		keySprite.position = CGPoint(x: 3*self.size.width/4, y: self.size.height/4)
		keySprite.stateMachine = MathematicsScene.introKeyMachine(forKey: keySprite)
		return keySprite
	}()
	
	/// convenience property to get all keys
	public override var allKeys:[KeySprite] {
		return [publicKeyNode, privateKeyNode]
	}
	
	private lazy var messageNode:Message3DNode = {
		let sceneSize = CGSize(width: 220, height: 220)
		let sceneNode = Message3DNode(viewportSize: sceneSize, messageScene: MathematicsScene.paperScene)
		sceneNode.position = CGPoint(x: self.size.width/2, y: 2*self.size.height/5)
		sceneNode.name = "messageNode"
		return sceneNode
	}()

	// MARK: Maths labels
	
	/// the message
	private lazy var mLabel:SKLabelNode = {
		let labelText = MathematicsScene.useRealValues ? "\(MathematicsScene.encryptor.message)" : "M"
		let label = RSAScene.mathsLabel(text: labelText, fontSize: 52, color: .black, bold: true)
		label.position =  CGPoint(x: self.size.width/2, y: self.messageNode.position.y+115)
		label.name = "mLabel"
		return label
	}()
	
	private lazy var nLabelText: SKLabelNode = {
		let labelText = MathematicsScene.useRealValues ? "\(MathematicsScene.encryptor.N)" : "N"
		let label = RSAScene.mathsLabel(text: labelText, fontSize: 44, color: .white, bold: true)
		label.zPosition = 3.0
		return label
	}()
	
	/// the public modulus
	private lazy var nLabel:SKNode = {
		let node = SKNode()
		node.position = CGPoint(x: (self.size.width/2), y: (3*self.size.height/4)-20)
		let label = nLabelText
		let background = RSAScene.backgroundSquare(forLabel: label, color: MathematicsScene.publicColor)
		node.addChild(background)
		node.addChild(label)
		let nodeName = "nLabel"
		[node, background, label].forEach { $0.name = nodeName }
		self.moveableLabels.insert(nodeName)
		node.alpha = 0 // initially hidden
		node.setScale(0.7)
		return node
	}()
	
	/// the public exponent
	private lazy var eLabel:SKNode = {
		let labelText = MathematicsScene.useRealValues ? "\(MathematicsScene.encryptor.e)" : "e"
		let label = RSAScene.mathsLabel(text: labelText, fontSize: 27, color: MathematicsScene.publicColor, bold: true)
		label.name = "eLabel"
		label.position = CGPoint(x: publicKeyNode.position.x, y: publicKeyNode.position.y+45)
		label.zPosition = 3.0
		return label
	}()
	
	/// the private exponent
	private lazy var dLabel:SKNode = {
		let labelText = MathematicsScene.useRealValues ? "\(MathematicsScene.encryptor.d)" : "d"
		let label = RSAScene.mathsLabel(text: labelText, fontSize: 27, color: MathematicsScene.privateColor, bold: true)
		label.name = "dLabel"
		label.position = CGPoint(x: privateKeyNode.position.x, y: privateKeyNode.position.y+45)
		label.zPosition = 3.0
		return label
	}()
	
	private lazy var modLabelText:SKLabelNode = {
		let label = RSAScene.mathsLabel(text: "mod", fontSize: 40, color: .white, bold: false)
		label.zPosition = 3.0
		return label
	}()
	
	/// the 'mod' label that is just for visual completeness
	private lazy var modLabel:SKNode = {
		let node = SKNode()
		node.position =  CGPoint(x: self.size.width-100, y: self.size.height-50)
		let label = modLabelText
		let background = RSAScene.backgroundSquare(forLabel: label, color: MathematicsScene.publicColor)
		node.addChild(background)
		node.addChild(label)
		let nodeName = "modLabel"
		[node, background, label].forEach { $0.name = nodeName }
		moveableLabels.insert(nodeName)
		return node
	}()
	
	/// the encrpyted message label
	private lazy var cLabel:SKLabelNode = {
		// encrypt the message using the encryptor
		let labelText = MathematicsScene.useRealValues ? "\(MathematicsScene.encryptor.cipherText)" : "C"
		let label = RSAScene.mathsLabel(text: labelText, fontSize: 52, color: .black, bold: true)
		label.position = CGPoint(x: self.mLabel.position.x, y: self.mLabel.position.y)
		label.name = "cLabel"
		label.alpha = 0
		return label
	}()
	
	private lazy var pLabel:SKNode = {
		let node = SKNode()
		node.position = CGPoint(x: nLabel.position.x-50, y: nLabel.position.y+80)
        let pText = MathematicsScene.useRealValues ? "\(MathematicsScene.encryptor.p)" : "p"
		let label = RSAScene.mathsLabel(text: pText, fontSize: 28, color: .white, bold: false)
		label.zPosition = 3.0
		let background = RSAScene.backgroundSquare(forLabel: label, color: MathematicsScene.privateColor)
		node.addChild(background)
		node.addChild(label)
		let nodeName = "pLabel"
		[node,background,label].forEach { $0.name = nodeName }
		self.moveableLabels.insert(nodeName)
		return node
	}()
	
	private lazy var qLabel:SKNode = {
		let node = SKNode()
		node.position = CGPoint(x: nLabel.position.x+50, y: nLabel.position.y+80)
        let qText = MathematicsScene.useRealValues ? "\(MathematicsScene.encryptor.q)" : "q"
		let label = RSAScene.mathsLabel(text: qText, fontSize: 28, color: .white, bold: false)
		label.zPosition = 3.0
		let background = RSAScene.backgroundSquare(forLabel: label, color: MathematicsScene.privateColor)
		node.addChild(background)
		node.addChild(label)
		let nodeName = "qLabel"
		[node,background,label].forEach { $0.name = nodeName }
		self.moveableLabels.insert(nodeName)
		return node
	}()
	
	/// simple non-interactive label that prompts the user to rotate the 3D message
	private lazy var dragToRotateLabel:SKLabelNode = {
		let label = RSAScene.mathsLabel(text: "Drag to rotate", fontSize: 12, color: .gray, bold: false)
		label.fontName = "Helvetica-Bold"
		label.name = "dragToRotate"
		label.position = CGPoint(x: self.size.width/2, y: messageNode.position.y-110)
		return label
	}()
	
	private lazy var promptLabel:SKLabelNode = {
		let label = RSAScene.mathsLabel(text: "Encrypt the message using the public key.", fontSize: 22, color: .black, bold: true)
		label.fontName = "Helvetica-Bold"
		label.name = "prompt"
		label.horizontalAlignmentMode = .left
		label.verticalAlignmentMode = .top
		label.position = CGPoint(x: 30, y: self.size.height-30)
		return label
	}()
	
	// MARK: State Machines
	
	/// bolier-plate for intro scene key machine
	private class func introKeyMachine(forKey key:KeySprite) -> GKStateMachine {
		let machine = GKStateMachine(states: [KeyDragState(key: key),
											  KeyWaitState(key: key),
											  KeyInactiveState(key: key)])
		// inactive initially if maths is enabled
		if MathematicsScene.mathsEnabled {
			machine.enter(KeyInactiveState.self)
		} else {
			machine.enter(KeyWaitState.self)
		}
		return machine
	}

	// MARK: Tracking Variables
	/// keeps track of whether we have created N yet. It only needs to be created at the start of the round
	private var nCreated = false
	private var currentlySelectedLabel:String?
	private var currentlyRepeatingNodes = [SKNode]()
	/// a set containing all moveable labels
	private var moveableLabels = Set<String>()
	/// a list of the current tasks that need to be completed before the maths animation can progress. a list of node names that must be removed
	private var mathsTasks = Set<String>() {
		didSet {
			if oldValue.count == 1 && mathsTasks.count == 0 {
				// if we removed the last task, complete the animation
				self.completeMathsAnimation()
			}
		}
	}
	
	// MARK: - Methods
	
	// MARK: Setup
	
	override public func sceneDidLoad() {
		super.sceneDidLoad()
		self.backgroundColor = .white
		// add the prompt
		self.addChild(promptLabel)
		// create the paper and the scene node
		self.addMessageSceneNode()
		// create the key sprites
		self.addKeySprites()
		// only add the maths labels if maths is enabled
		self.addMathsLabelsIfNeeded()
		self.startInitialMathsAnimationsIfNeeded()
	}

	private func addMessageSceneNode() {
		self.addChild(messageNode)
		self.addChild(dragToRotateLabel)
	}
	
	private func addKeySprites() {
		self.addChild(publicKeyNode)
		self.addChild(privateKeyNode)
	}
	
	private func addMathsLabelsIfNeeded() {
		guard MathematicsScene.mathsEnabled else { return }
		// add the maths labels to the scene
		[mLabel, eLabel, dLabel, modLabel, nLabel, cLabel, pLabel, qLabel].forEach {
			self.addChild($0)
		}
		// update the prompt message to reflect the action that is required
		promptLabel.text = "Create N: drag p and q together to multiply them."
	}
	
	private func startInitialMathsAnimationsIfNeeded() {
        guard MathematicsScene.mathsEnabled else { return }
		guard !nCreated else { return }
		// so that we cannot use the keys until we create N
		self.sceneStateMachine.enter(SceneAnimatingState.self)
		// start the prompting animation to drag p and q together
		self.mathsCreateValueRepeat(node: pLabel, shrinkPosition: qLabel.position)
		self.mathsCreateValueRepeat(node: qLabel, shrinkPosition: pLabel.position)
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
		// start rotating the cube/message
		if nodeName == "messageNode" {
			self.messageNode.stateMachine.state(forClass: MessageDraggingState.self)?.startMovingPoint = point
			self.messageNode.stateMachine.enter(MessageRotatingState.self)
		}
		// start moving the key node
		else if nodeName.contains("KeyNode") {
			guard let keyNode = node as? KeySprite else { return }
			keyNode.stateMachine.state(forClass: KeyDragState.self)?.startMovingPoint = point
			keyNode.stateMachine.enter(KeyDragState.self)
		}
	}
	
	override public func touchMoved(toPoint point: CGPoint) {
		// call the implementation in RSAScene
		super.touchMoved(toPoint: point)
		// update objects if we need to
		self.messageNode.updateRotationIfRotating(newPoint: point)
	}
	
	override public func touchUp(atPoint point: CGPoint) {
		if movedSignificantlyThisTouch, let label = currentlySelectedLabel, self.moveableLabels.contains(label) {
			guard let movingLabel = self.childNode(withName: label + "-copy") else { return }
			if !nCreated {
				if (label == "pLabel" && self.touchingOtherLabel(point: point, label: "qLabel")) || (label == "qLabel" && self.touchingOtherLabel(point: point, label: "pLabel")) {
					self.showNLabelForFirstTime()
					// make the keys interactable
					[publicKeyNode, privateKeyNode].forEach {
						$0.stateMachine.enter(KeyWaitState.self)
					}
					// update the prompt
					self.promptLabel.text = "Encrypt the message using the public key."
				}
			}
			// start any initial animations again if needed
			self.startInitialMathsAnimationsIfNeeded()
			if let blinking = self.draggedLabelOnTopOfBlinkingLabel(point: point, label: label) {
				// we have made contact with the correct blinking label, so merge the dragging label to the correct position
				self.alignDraggingLabelWithBlinkingLabel(dragging: movingLabel, blinking: blinking)
			} else {
				// not in the right place, just drop the label
				self.dropDraggingLabel(movingLabel, label: label)
			}
			self.run(MathematicsScene.dropKeySound)
		}
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
		// set the stop moving points, so we can compute the fling
		self.stopKeysMovingIfNeeded(at: point)
		// stop the cube rotation
		self.messageNode.stateMachine.enter(MessageWaitingState.self)
	}
	
	private func touchingOtherLabel(point:CGPoint, label:String) -> Bool {
		let nodes = self.nodes(at: point)
		for node in nodes {
			guard let nodeName = node.name else { continue }
			guard nodeName == label else { continue }
			return true
		}
		return false
	}
	
	private func draggedLabelOnTopOfBlinkingLabel(point:CGPoint, label:String) -> SKNode? {
		let nodes = self.nodes(at: point)
		for node in nodes {
			guard let nodeName = node.name else { continue }
			guard nodeName == (label + "-blinking") else { continue }
			return node
		}
		return nil
	}
	
	private func showNLabelForFirstTime() {
		let scale = SKAction.scale(to: 1, duration: 0.2)
		let fade = SKAction.fadeIn(withDuration: 0.2)
		let grouped = SKAction.group([scale,fade])
		self.nLabel.run(grouped)
		self.nCreated = true
		self.sceneStateMachine.enter(SceneWaitState.self)
		self.stopForeverAnimations()
	}
	
	/// moves a maths label that we are dragging on top of the blinking label perfectly, and removes the blinking label
	private func alignDraggingLabelWithBlinkingLabel(dragging:SKNode, blinking:SKNode) {
		// move the dragging label to the correct position
		let fadeIn = SKAction.fadeIn(withDuration: 0.2)
		fadeIn.timingMode = .easeOut
		let scale = SKAction.scale(to: 1, duration: 0.2)
		scale.timingMode = .easeOut
		let moveToBlinking = SKAction.move(to: blinking.position, duration: 0.2)
		moveToBlinking.timingMode = .easeOut
		let group = SKAction.group([fadeIn, scale, moveToBlinking])
		dragging.run(group)
		// fade out and remove the blinking label, we no longer need it
		if let blinkingName = blinking.name {
			self.mathsTasks.remove(blinkingName)
		}
		let fadeOutBlinking = SKAction.fadeOut(withDuration: 0.3)
		let removeBlinking = SKAction.removeFromParent()
		let fadeRemove = SKAction.sequence([fadeOutBlinking,removeBlinking])
		blinking.run(fadeRemove)
	}
	
	/// drops the dragging label into the ether, and fades in the original label once more
	private func dropDraggingLabel(_ node:SKNode, label:String) {
		let scaleUp = SKAction.scale(to: 0.6, duration: 0.2)
		let fadeOut = SKAction.fadeOut(withDuration: 0.2)
		let remove = SKAction.removeFromParent()
		let fadeAnimation = SKAction.group([scaleUp, fadeOut])
		let removeAnimation = SKAction.sequence([fadeAnimation,remove])
		node.removeAction(forKey: "startMovingAction")
		node.run(removeAnimation, withKey: "removeAnimation")
		// fade the original in
		if let originalLabel = self.childNode(withName: label) {
			let fadeIn = SKAction.fadeIn(withDuration: 0.2)
			originalLabel.run(fadeIn)
		}
	}
	
	override public func bodyContact(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
		super.bodyContact(firstBody: firstBody, secondBody: secondBody)
        // we only care about contact where the second item is the box
        guard secondBody.categoryBitMask == PhysicsCategory.box else { return }
        // determine the first body
        switch firstBody.categoryBitMask {
        case PhysicsCategory.publicKeyA:
			guard let state = publicKeyNode.stateMachine.currentState, state.isKind(of: KeyDragState.self) else { return }
            self.publicKeyContact()
        case PhysicsCategory.privateKeyA:
			guard let state = privateKeyNode.stateMachine.currentState, state.isKind(of: KeyDragState.self) else { return }
            self.privateKeyContact()
        default:
            return
        }
	}
    
    private func publicKeyContact() {
        // do nothing if we are currently animating
		guard let state = sceneStateMachine.currentState, state.isKind(of: SceneWaitState.self) else { return }
		sceneStateMachine.enter(SceneAnimatingState.self)
		// switch on that state of the paper scene
		guard let paperState = messageNode.sceneStateMachine.currentState else { return }
        switch paperState {
        case is PaperNormalState:
            // perform the maths animation if enabled, otherwise just morph
			if MathematicsScene.mathsEnabled {
				self.setupMathsLabelsForInteraction()
				// play a small click
				self.messageNode.run(MathematicsScene.initialTapSound)
			} else {
				self.messageNode.sceneStateMachine.enter(PaperEncryptedState.self)
				// inform that we are no longer animating after the animation when we are not using maths animations
				self.setSceneNotAnimating(afterDelay: PaperEncryptedState.moveToCryptoTime)
				// update the prompt
				self.promptLabel.text = "Decrypt the message using the private key."
			}
        case is PaperEncryptedState:
			// move to the question mark state
			self.messageNode.sceneStateMachine.enter(PaperErrorState.self)
			self.setSceneNotAnimating(afterDelay: PaperErrorState.errorFlashTime*3) // *3 => change, wait, change
		default:
			return
        }
    }
    
    private func privateKeyContact() {
        // do nothing if we are currently animating
        guard let state = sceneStateMachine.currentState, state.isKind(of: SceneWaitState.self) else { return }
        sceneStateMachine.enter(SceneAnimatingState.self)
		// switch on that state of the paper scene
		guard let paperState = messageNode.sceneStateMachine.currentState else { return }
        switch paperState {
        case is PaperNormalState:
			// do the question mark animation
			self.messageNode.sceneStateMachine.enter(PaperErrorState.self)
			self.setSceneNotAnimating(afterDelay: PaperErrorState.errorFlashTime*3) // *3 => change, wait, change
        case is PaperEncryptedState:
            // perform the maths animation is enabled, otherwise just morph
			if MathematicsScene.mathsEnabled {
				self.setupMathsLabelsForInteraction()
				// play a small click
				self.messageNode.run(MathematicsScene.initialTapSound)
			} else {
				self.messageNode.sceneStateMachine.enter(PaperNormalState.self)
				// inform that we are no longer animating after the animation when we are not using maths animations
				self.setSceneNotAnimating(afterDelay: PaperNormalState.moveToPaperTime)
				// update the prompt
				self.promptLabel.text = "Encrypt the message using the public key."
			}
		default:
			return
        }
    }
	
	private func stopForeverAnimations() {
		defer {
			self.currentlyRepeatingNodes = []
		}
		for node in currentlyRepeatingNodes {
			node.removeFromParent()
		}
	}
	
	
	/// puts all the automatically moving maths labels in the correct places, starts all the correct looping animations.
	/// generally gets the scene ready for the interaction phase
	private func setupMathsLabelsForInteraction() {
		guard let paperState = self.messageNode.sceneStateMachine.currentState else { return }
		// in prep for the maths animation
		self.stopForeverAnimations()
		// determine the correct labels
		let encrypting = paperState is PaperNormalState
		let keyLabel:SKNode = encrypting ? eLabel : dLabel
		let oldMessageLabel:SKLabelNode = encrypting ? mLabel : cLabel
		
		// animate key label
		let keyLabelNewPosition = CGPoint(x: (self.size.width/2)-65, y: oldMessageLabel.position.y+34)
		let moveKeyLabel = SKAction.move(to: keyLabelNewPosition, duration: MathematicsScene.mathsAnimationMoveTime)
		moveKeyLabel.timingMode = .easeOut
		let keyLabelCopy = keyLabel.copy() as! SKNode
		keyLabelCopy.name = (keyLabel.name ?? "") + "-copy"
		keyLabel.alpha = 0
		self.addChild(keyLabelCopy)
		keyLabelCopy.run(moveKeyLabel)
		// mod label
		let modPlaceholderPosition = CGPoint(x: self.size.width/2, y: oldMessageLabel.position.y)
		self.moveHiddenCopyToLocationAndThenBlink(node: modLabelText, location: modPlaceholderPosition)
		// n label
		let nPlaceholderOffset:CGFloat = MathematicsScene.useRealValues ? 120 : 90
		let nPlaceholderPosition = CGPoint(x: (self.size.width/2)+nPlaceholderOffset, y: oldMessageLabel.position.y)
		self.moveHiddenCopyToLocationAndThenBlink(node: nLabelText, location: nPlaceholderPosition)
		// old message
		let amountToMove:CGFloat = oldMessageLabel.text!.count == 1 ? 105 : 115
		let oldMessageEquationPosition = CGPoint(x: (self.size.width/2)-amountToMove, y: oldMessageLabel.position.y)
		let moveOldMessageAnimation = SKAction.move(to: oldMessageEquationPosition, duration: MathematicsScene.mathsAnimationMoveTime)
		moveOldMessageAnimation.timingMode = .easeOut
		oldMessageLabel.run(moveOldMessageAnimation)
		// update the prompt
		self.promptLabel.text = "Drag the labels to the correct place."
	}
	
	private func moveHiddenCopyToLocationAndThenBlink(node:SKLabelNode, location:CGPoint) {
		let moveCopyAction = SKAction.move(to: location, duration: MathematicsScene.mathsAnimationMoveTime)
		let fadedDown = SKAction.fadeAlpha(to: 0.05, duration: 0.65)
		fadedDown.timingMode = .easeOut
		let fadedUp = SKAction.fadeAlpha(to: 0.15, duration: 0.65)
		fadedUp.timingMode = .easeOut
		let fadeCycle = SKAction.sequence([fadedDown,fadedUp])
		let fadeForeverCycle = SKAction.repeatForever(fadeCycle)
		let nodeCopySequence = SKAction.sequence([moveCopyAction,fadeForeverCycle])
		let nodeCopy = node.copy() as! SKLabelNode
		nodeCopy.fontColor = .black
		nodeCopy.alpha = 0
		let blinkingName = (node.name ?? "") + "-blinking"
		mathsTasks.insert(blinkingName)
		nodeCopy.name = blinkingName
		self.addChild(nodeCopy)
		nodeCopy.run(nodeCopySequence)
	}
	
	/// finishes off the maths animation after the user has dragged the labels to the correct position
	private func completeMathsAnimation() {
		guard let paperState = self.messageNode.sceneStateMachine.currentState else { return }
		// determine the correct state and labels
		let encrypting = paperState is PaperNormalState
		let keyLabel:SKNode = encrypting ? eLabel : dLabel
		let oldMessageLabel:SKLabelNode = encrypting ? mLabel : cLabel
		let newMessageLabel:SKLabelNode = encrypting ? cLabel : mLabel
		// create the action
		let centerPosition = CGPoint(x: self.size.width/2, y: oldMessageLabel.position.y)
		let pauseShrinkFade = MathematicsScene.pauseShrinkFade(toPosition: centerPosition)
		let remove = SKAction.removeFromParent()
		let pauseShrinkFadeRemove = SKAction.sequence([pauseShrinkFade,remove])
		// run action on most ephemeral labels
		self.runActionOnCopyIfCopyExists(action: pauseShrinkFadeRemove, node: keyLabel)
		self.runActionOnCopyIfCopyExists(action: pauseShrinkFadeRemove, node: modLabel)
		self.runActionOnCopyIfCopyExists(action: pauseShrinkFadeRemove, node: nLabel)
		// move the old message label ready for next animation
		let grow = SKAction.scale(to: 1, duration: 0)
		let moveToCenter = SKAction.move(to: centerPosition, duration: 0)
		let oldMessageSequence = SKAction.sequence([pauseShrinkFade,grow,moveToCenter])
		oldMessageLabel.run(oldMessageSequence)
		// fade in the stuff for next time
		let waitNewLabel = SKAction.wait(forDuration: MathematicsScene.mathsAnimationPauseTime)
		let fadeBackIn = SKAction.fadeIn(withDuration: MathematicsScene.mathsAnimationMoveTime)
		fadeBackIn.timingMode = .easeIn
		let fadeBackSequence = SKAction.sequence([waitNewLabel,fadeBackIn])
		newMessageLabel.run(fadeBackSequence)
		keyLabel.run(fadeBackSequence)
		modLabel.run(fadeBackSequence)
		nLabel.run(fadeBackSequence)
		// update the message
		self.updateMessageForCompletedMathsAnimation(encrypting: encrypting)
	}
	
	private func updateMessageForCompletedMathsAnimation(encrypting:Bool) {
		let waitUntilEnd = SKAction.wait(forDuration: MathematicsScene.mathsAnimationMoveTime + 0.8)
		let morphAction = SKAction.customAction(withDuration: 0) { _, _ in
			if encrypting {
				self.messageNode.sceneStateMachine.enter(PaperEncryptedState.self)
				// update the prompt
				self.promptLabel.text = "Decrypt the message using the private key."
			} else {
				self.messageNode.sceneStateMachine.enter(PaperNormalState.self)
				// update the prompt
				self.promptLabel.text = "Encrypt the message using the public key."
			}
		}
		let notAnimating = SKAction.customAction(withDuration: 0) { _, _ in
			self.sceneStateMachine.enter(SceneWaitState.self)
		}
		let morphSeq = SKAction.sequence([waitUntilEnd,morphAction,notAnimating])
		self.run(morphSeq)
		self.setSceneNotAnimating(afterDelay: PaperNormalState.moveToPaperTime + 0.8)
	}
	
	private func runActionOnCopyIfCopyExists(action:SKAction,node:SKNode) {
		if let nodeName = node.name {
			if let nodeCopy = self.childNode(withName: nodeName + "-copy") {
				nodeCopy.run(action)
			}
		}
	}
	
	private func mathsCreateValueRepeat(node:SKNode, shrinkPosition:CGPoint) {
		let shrinkFade = MathematicsScene.pauseShrinkFade(toPosition: shrinkPosition)
		let initialPosition = node.position
		let moveBack = SKAction.move(to: initialPosition, duration: 0)
		let fadeUp = SKAction.fadeIn(withDuration: 0)
		let scaleUp = SKAction.scale(to: 1, duration: 0)
		let nodeCopy = node.copy() as! SKNode
		node.zPosition = 2.0
		nodeCopy.zPosition = 1.0
		nodeCopy.name = (node.name ?? "") + "-animating"
		nodeCopy.alpha = 0.5
		let sequence = SKAction.sequence([shrinkFade,moveBack,fadeUp,scaleUp])
		let forever = SKAction.repeatForever(sequence)
		self.addChild(nodeCopy)
		nodeCopy.run(forever)
		// keep track that this node is repeating
		self.currentlyRepeatingNodes.append(nodeCopy)
	}
    
    private class func pauseShrinkFade(toPosition newPosition:CGPoint) -> SKAction {
        let pauseTime = SKAction.wait(forDuration: MathematicsScene.mathsAnimationPauseTime)
        let shrinkAnimation = SKAction.scale(to: 0.6, duration: MathematicsScene.mathsAnimationShrinkFadeTime)
        shrinkAnimation.timingMode = .easeIn
        let fadeAnimation = SKAction.fadeOut(withDuration: MathematicsScene.mathsAnimationShrinkFadeTime/1.2)
        fadeAnimation.timingMode = .easeIn
        let animateToPosition = SKAction.move(to: newPosition, duration: MathematicsScene.mathsAnimationShrinkFadeTime)
        animateToPosition.timingMode = .easeIn
        let group = SKAction.group([shrinkAnimation, fadeAnimation, animateToPosition])
        return SKAction.sequence([pauseTime,group])
    }
	
	override public func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // make sure that the maths labels are above the keys if needed
        if MathematicsScene.mathsEnabled {
            self.move(node: eLabel, above: publicKeyNode, by: 45.0)
            self.move(node: dLabel, above: privateKeyNode, by: 45.0)
        }
		// update finger position or exit
        guard let point = currentFingerPosition else { return }
        // ignore movement if position is outside scene (smaller margin on bottom)
        guard RSAScene.insideEdgeMargin(scene: self, point: point) == false else {
            // stop moving keys if the touch is outside the margin
			self.stopKeysMovingIfNeeded(at: point)
			return
        }
		for key in allKeys {
			if let state = key.stateMachine.currentState, state.isKind(of: KeyDragState.self) {
				key.updatePosition(to: point)
			}
		}
		guard movedSignificantlyThisTouch, let label = currentlySelectedLabel, self.moveableLabels.contains(label) else { return }
		if let movingLabel = self.childNode(withName: label + "-copy") {
			movingLabel.position = point
		} else {
			guard let regular = self.childNode(withName: label) else { return }
			self.stopForeverAnimations() // stop the forever animations
			self.createDraggingLabel(fromLabel: regular, name: label)
		}
	}
	
	private func createDraggingLabel(fromLabel label:SKNode, name:String) {
		let copy = label.copy() as! SKNode
		label.alpha = 0
		copy.name = name + "-copy"
		for child in copy.children {
			child.name = name + "-copy"
		}
		self.addChild(copy)
		let scale = SKAction.scale(to: 1.2, duration: 0.2)
		let fade = SKAction.fadeAlpha(to: 0.8, duration: 0.2)
		let startMovingAction = SKAction.group([scale,fade])
		copy.run(startMovingAction, withKey: "startMovingAction")
		self.run(MathematicsScene.pickupKeySound)
	}
	
	private func showInfoPanel(forLabel label:String) {
		// play a little click sound after the delegation call
		var shouldClick = true
        defer {
			if shouldClick { self.run(MathematicsScene.popupSound) }
		}
		switch label {
		case "mLabel":
			self.informationDelegate?.presentInformationPopup(title: "Message", message: "This is the message that we will encrypt, in the format of a number, so we can do the required maths operations. We can encrypt the message by using the Public Modulus and Public Exponent.")
		case "cLabel":
			self.informationDelegate?.presentInformationPopup(title: "Ciphertext", message: "This is the encrypted message. We can only convert this back to the original message with the private key (by using the Public Modulus and Private Exponent).")
		case "modLabel":
			self.informationDelegate?.presentInformationPopup(title: "Modulo Operator", message: "This is the mathematical operator that is used to calculate the remainder after dividing some number by another number.\n\nModulo arithmetic is widely used in computer science for all sorts of different applications.")
		case "nLabel":
			self.informationDelegate?.presentInformationPopup(title: "Public Modulus", message: "This number is really easy to calculate. It is calculated by multiplying p and q, and is used when we encrypt the message and also when we decrypt the cipher text.\n\nAlthough, we can not figure out p and q just given this number (more on that later)!")
		case "eLabel":
			self.informationDelegate?.presentInformationPopup(title: "Public Exponent", message: "This is the one of the parts of the public key.\n\nIt is used to convert the message into the encrypted message (ciphertext), along with the public modulus N. It can be any number that we want that is co-prime to (p-1)*(q-1). This means the only factor that they have in common is 1.\n\nAn easy way to this number is to just use another prime number, because prime numbers share no factors apart from 1 with any other number.")
		case "dLabel":
			self.informationDelegate?.presentInformationPopup(title: "Private Exponent", message: "This is the one of the parts of the private key.\n\nIt is used to convert the encrypted message (ciphertext) back to the original message, along with the public modulus N.\n\nIt is the unique integer such that e*d=1*mod(p-1)*(q-1) (there's only 1 possible value that d can be to make this equation work). You can only easily calculate this number if you originally knew the 2 prime numbers p and q.")
		case "pLabel":
            self.informationDelegate?.presentInformationPopup(title: "Prime p", message: "This is just a prime number that we pick (and keep secret!). It can be anything we want with 2 simple rules:\n   1. it must be a prime number\n   2. it must be different from q\n\nWe multiply p and q to calculate the public modulus N.")
		case "qLabel":
			self.informationDelegate?.presentInformationPopup(title: "Prime q", message: "This is just a prime number that we pick (and keep secret!). It can be anything we want with 2 simple rules:\n   1. it must be a prime number\n   2. it must be different from p\n\nWe multiply p and q to calculate the public modulus N.")
		default:
			// no click sound if we present to information popup
			shouldClick = false
		}
	}
	
}
