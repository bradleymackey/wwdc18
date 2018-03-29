//
//  InteractiveScene.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 22/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

/*
PEOPLE SOUNDS:
https://freesound.org/people/marcello777/
https://freesound.org/people/AderuMoro
*/

import Foundation
import SpriteKit

/// the interactive scene used to display the real scenario
/// - note: the aim of this scene is to give the user a real understanding of RSA and how it is really used
public final class InteractiveScene: RSAScene  {
    
    public enum SceneCharacters: String {
        case alice = "aliceCharacter"
        case bob = "bobCharacter"
        case eve = "eveCharacter"
    }
	
	// MARK: - Properties
	
	// MARK: Constants
    
    public static var fadedDown:CGFloat = 0.25
    public static var fadeTime:TimeInterval = 0.2
    public static var invalidPulseTime:TimeInterval = 0.2
    public static var cubeChangeTime:TimeInterval = 0.5
    
    public static var aliceMessage = "Hello world. This is a really long message just to test how thingsk sdf sdf skjdf ksjd fkshdf ksjdhfksjhdfsk jfskjdfhskjd fksd fksjhdf ksjdfhks dfkshdf ksfhskfhkh."
    public static var bobMessage = "This is a test."
    public static var eveMessage = "I am a 1337 hacker!!"
	
	// MARK: Instance Variables
	
	public static var paperScene = Message3DScene(message: InteractiveScene.aliceMessage)
	
	private lazy var aliceSound = SKAction.playSoundFileNamed("hellolady1.caf", waitForCompletion: false)
	private lazy var bobSound = SKAction.playSoundFileNamed("helloman.caf", waitForCompletion: false)
	private lazy var eveSound = SKAction.playSoundFileNamed("hellolady2.caf", waitForCompletion: false)
	private lazy var encryptSound = SKAction.playSoundFileNamed("encrypt.caf", waitForCompletion: false)
	private lazy var decryptSound = SKAction.playSoundFileNamed("decrypt.caf", waitForCompletion: false)
	private lazy var failSound = SKAction.playSoundFileNamed("fail.caf", waitForCompletion: false)

    
    /// for fading items up that come into focus
    private let fadeUp:SKAction = {
        let action = SKAction.fadeAlpha(to: 1, duration: InteractiveScene.fadeTime)
        action.timingMode = .easeOut
        return action
    }()
    
    /// for fading items down that lose focus
    private let fadeDown:SKAction = {
        let action = SKAction.fadeAlpha(to: InteractiveScene.fadedDown, duration: InteractiveScene.fadeTime)
        action.timingMode = .easeOut
        return action
    }()
	
	private lazy var messageNode:Message3DNode = {
		let sceneSize = CGSize(width: 120, height: 120)
		let sceneNode = Message3DNode(viewportSize: sceneSize, messageScene: InteractiveScene.paperScene)
		sceneNode.position = CGPoint(x: aliceCharacter.position.x, y: aliceCharacter.position.y + 140)
		sceneNode.name = "messageNode"
		return sceneNode
	}()
	
	private lazy var aliceCharacter:CharacterSprite = {
        let alice = CharacterSprite(characterName: "Alice", waiting: "💁🏽‍♀️", inRange: "👩🏽‍💻", success: "🙆🏽‍♀️", fail: "🤦🏽‍♀️")
		alice.name = "aliceCharacter"
        alice.position = CGPoint(x: self.size.width/4, y: 40)
		return alice
	}()
	
	private lazy var bobCharacter:CharacterSprite = {
        let bob = CharacterSprite(characterName: "Bob", waiting: "💁🏼‍♂️", inRange: "👨🏼‍💻", success: "🙆🏼‍♂️", fail: "🤦🏼‍♂️")
		bob.name = "bobCharacter"
        bob.position = CGPoint(x: 3*self.size.width/4, y: 40)
		return bob
	}()
	
	private lazy var eveCharacter:CharacterSprite = {
        let eve = CharacterSprite(characterName: "Eve", waiting: "💁🏻‍♀️", inRange: "👩🏻‍💻", success: "🙆🏻‍♀️", fail: "🤦🏻‍♀️")
		eve.name = "eveCharacter"
        eve.position = CGPoint(x: 2*self.size.width/4, y: 3*self.size.height/4)
		return eve
	}()
	
	private lazy var alicePublicKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.publicColor, owner: .alice, type: .`public`, size: 45)
		keySprite.name = "alicePublicKeyNode"
		keySprite.position = CGPoint(x: (self.size.width/2)-40, y: (self.size.height/5)+10)
		return keySprite
	}()
	
	private lazy var alicePrivateKeyNode:KeySprite = {
        let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.privateColor, owner: .alice, type: .`private`, size: 45)
		keySprite.name = "alicePrivateKeyNode"
		keySprite.position = CGPoint(x: self.size.width/9, y: self.size.height/5)
		return keySprite
	}()
	
	private lazy var bobPublicKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.publicColor, owner: .bob, type: .`public`, size: 45)
		keySprite.name = "bobPublicKeyNode"
		keySprite.position = CGPoint(x: (self.size.width/2)+40, y: (self.size.height/5)+10)
		return keySprite
	}()
	
	private lazy var bobPrivateKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.privateColor, owner: .bob, type: .`private`, size: 45)
		keySprite.name = "bobPrivateKeyNode"
		keySprite.position = CGPoint(x: 8*self.size.width/9, y: self.size.height/5)
		return keySprite
	}()
    
    private lazy var alicePublicLabel:SKLabelNode = {
        let label = InteractiveScene.keyLabel(text: "Alice")
        self.updatePosition(forNode: label, aboveNode: alicePublicKeyNode)
        return label
    }()
    
    private lazy var alicePrivateLabel:SKLabelNode = {
        let label = InteractiveScene.keyLabel(text: "Alice")
        self.updatePosition(forNode: label, aboveNode: alicePrivateKeyNode)
        return label
    }()
    
    private lazy var bobPublicLabel:SKLabelNode = {
        let label = InteractiveScene.keyLabel(text: "Bob")
		self.updatePosition(forNode: label, aboveNode: bobPublicKeyNode)
        return label
    }()
    
    private lazy var bobPrivateLabel:SKLabelNode = {
        let label = InteractiveScene.keyLabel(text: "Bob")
		self.updatePosition(forNode: label, aboveNode: bobPrivateKeyNode)
        return label
    }()
	
	private lazy var messageLabel:SKLabelNode = {
		let label = InteractiveScene.keyLabel(text: "Alice's Message")
		label.fontSize = 10
		label.numberOfLines = 2
		label.lineBreakMode = .byWordWrapping
		self.updatePosition(forNode: label, aboveNode: messageNode, by: 45.0)
		return label
	}()
    
    private lazy var aliceCage:CageSprite = {
        let cageSize = CGSize(width: alicePrivateKeyNode.size.width+50, height: alicePrivateKeyNode.size.height+50)
        let cage = CageSprite(size: cageSize)
        return cage
    }()
    
    private lazy var bobCage:CageSprite = {
        let cageSize = CGSize(width: bobPrivateKeyNode.size.width+50, height: bobPrivateKeyNode.size.height+50)
        let cage = CageSprite(size: cageSize)
        return cage
    }()
    
    /// convenience property to get all characters
    private lazy var allCharacters:[CharacterSprite] = {
        return [aliceCharacter, bobCharacter, eveCharacter]
    }()
    
    /// convenience property to get all keys
    private lazy var allKeys:[KeySprite] = {
        return [alicePublicKeyNode, alicePrivateKeyNode, bobPublicKeyNode, bobPrivateKeyNode]
    }()
    
    private lazy var allMoveable:[MoveableSprite] = {
        var moveable:[MoveableSprite] = allKeys
        moveable.append(messageNode)
        return moveable
    }()
    
    private lazy var keyToKeyLabel:[KeySprite:SKLabelNode] = {
        return [alicePublicKeyNode:alicePublicLabel, alicePrivateKeyNode:alicePrivateLabel, bobPublicKeyNode:bobPublicLabel, bobPrivateKeyNode:bobPrivateLabel]
    }()
	
	// MARK: Tracking variables
    
    /// the character that is currently in range of the message
    private weak var characterInRange:CharacterSprite?
    /// whether the box animation is currently taking place
    private var currentlyAnimating = false
	/// the label that says whos message this was before it gets locked
	private var previousLockedMessage:String?
	/// keeps track of if no characters are currently focused (for efficiency)
	private var noCharactersFocused = false
	/// keeps track of if no keys are currently focused (for efficiency)
	private var noKeysFocused = false

	
	// MARK: - Setup
	
	public override func sceneDidLoad() {
		super.sceneDidLoad()
		self.backgroundColor = .white
        self.addNodesToScene()
		// focus on alice, our first character
		self.setCharacterFocusIfNeeded(character: self.aliceCharacter)
	}
    
    private func addNodesToScene() {
        // characters
        for character in allCharacters {
            self.addChild(character)
        }
        // the 3d message
        self.addChild(messageNode)
		self.addChild(messageLabel)
        // keys and labels
        for (key,keyLabel) in keyToKeyLabel {
            // add the key before the label so it can be positioned above it
            self.addChild(key)
            self.addChild(keyLabel)
        }
		
		let point = CGPoint(x: self.size.width/9, y: self.size.height)
        let rope = RopeSprite(attachmentPoint: point, attachedElement: self.aliceCage, length: 75)
		self.addChild(rope)
		rope.addRopeElementsToScene()
		let otherPoint = CGPoint(x: 8*self.size.width/9, y: self.size.height)
		let otherRope = RopeSprite(attachmentPoint: otherPoint, attachedElement: self.bobCage, length: 75)
		self.addChild(otherRope)
		otherRope.addRopeElementsToScene()
        
    }
	
	// MARK: - Methods
    
    private class func keyLabel(text:String) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "SanFransico")
        label.text = text
        label.fontColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        label.fontSize = 12
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        return label
    }
	
	override public func touchDown(atPoint point: CGPoint) {
		super.touchDown(atPoint: point)
        // get the node that we have just touched
        let node = self.atPoint(point)
        // ensure that the node has a name
        guard let nodeName = node.name else { return }
        switch (nodeName) {
        case "alicePublicKeyNode":
            self.alicePublicKeyNode.startMoving(initialPoint: point)
        case "alicePrivateKeyNode":
            self.alicePrivateKeyNode.startMoving(initialPoint: point)
        case "bobPublicKeyNode":
            self.bobPublicKeyNode.startMoving(initialPoint: point)
        case "bobPrivateKeyNode":
            self.bobPrivateKeyNode.startMoving(initialPoint: point)
        case "messageNode":
            self.messageNode.startMoving(initialPoint: point)
        default:
            return
        }
	}
	
	override public func touchMoved(toPoint point: CGPoint) {
		super.touchMoved(toPoint: point)
	}
	
	override public func touchUp(atPoint point: CGPoint) {
		super.touchUp(atPoint: point)
		// mark that all moveables are no longer being moved by the user
        for moveable in allMoveable {
            moveable.stopMoving(at: point)
        }
	}
	
	public override func bodyContact(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
		super.bodyContact(firstBody: firstBody, secondBody: secondBody)
        // we only care about contact when the second item is the box
        guard secondBody.categoryBitMask == PhysicsCategory.box else { return }
        // determine which item collided with the box
        switch firstBody.categoryBitMask {
        case PhysicsCategory.publicKeyA:
			guard alicePublicKeyNode.isBeingMoved else { return }
			self.publicKeyContact(keyOwner: .alice)
        case PhysicsCategory.privateKeyA:
			guard alicePrivateKeyNode.isBeingMoved else { return }
            self.privateKeyContact(keyOwner: .alice)
        case PhysicsCategory.publicKeyB:
			guard bobPublicKeyNode.isBeingMoved else { return }
            self.publicKeyContact(keyOwner: .bob)
        case PhysicsCategory.privateKeyB:
			guard bobPrivateKeyNode.isBeingMoved else { return }
            self.privateKeyContact(keyOwner: .bob)
        default:
            return
        }
	}
    
    private func publicKeyContact(keyOwner: KeyOwner) {
        guard !currentlyAnimating else { return }
        currentlyAnimating = true
        switch (InteractiveScene.paperScene.paperState) {
        case .unencrypted:
            // mark who has encrypted this
            InteractiveScene.paperScene.encryptedBy = keyOwner
            // mark the new state
            InteractiveScene.paperScene.paperState = .encrypted
            // perform the maths animation if enabled, otherwise just morph
            InteractiveScene.paperScene.morphToCrypto(duration: InteractiveScene.cubeChangeTime)
            // inform that we are no longer animating after the animation when we are not using maths animations
            DispatchQueue.main.asyncAfter(deadline: .now() + InteractiveScene.cubeChangeTime) {
                self.currentlyAnimating = false
            }
			// the character success animation
            self.characterInRange?.successAnimation()
			// update the label above the message
			if let messageText = self.messageLabel.text {
				let lockedMessage = keyOwner == .alice ? aliceCharacter.lockedByMessage : bobCharacter.lockedByMessage
				self.messageLabel.text = messageText + "\n" + lockedMessage
				// the previous message before we lock the message
				self.previousLockedMessage = messageText
			}
			// play the ecnrypt sound
			self.messageNode.run(encryptSound)
        case .encrypted:
            // do the question mark animation
            self.invalidContactAnimation(forState: .encrypted)
            self.characterInRange?.failAnimation()
			// play the fail sound
			self.messageNode.run(failSound)
        }
    }
    
    private func privateKeyContact(keyOwner: KeyOwner) {
        guard !currentlyAnimating else { return }
        currentlyAnimating = true
        switch (InteractiveScene.paperScene.paperState) {
        case .unencrypted:
            // do the question mark animation
            self.invalidContactAnimation(forState: .unencrypted)
            self.characterInRange?.failAnimation()
			// play the fail sound
			self.messageNode.run(failSound)
        case .encrypted:
            // the decryptor key must be owned by same as encryptor
            guard let encryptor = InteractiveScene.paperScene.encryptedBy, keyOwner == encryptor else {
                self.invalidContactAnimation(forState: .encrypted)
                self.characterInRange?.failAnimation()
				// play the fail sound
				self.messageNode.run(failSound)
                return
            }
            // mark the new state
            InteractiveScene.paperScene.paperState = .unencrypted
            // perform the maths animation if enabled, otherwise just morph
            InteractiveScene.paperScene.morphToPaper(duration: InteractiveScene.cubeChangeTime)
            // inform that we are no longer animating after the animation when we are not using maths animations
            DispatchQueue.main.asyncAfter(deadline: .now() + InteractiveScene.cubeChangeTime) {
                self.currentlyAnimating = false
            }
            self.characterInRange?.successAnimation()
			// set the label above the message back to before it was encrypted
			if let message = self.previousLockedMessage {
				self.messageLabel.text = message
			}
			// play the decrypt sound
			self.messageNode.run(decryptSound)
        }
    }

    /// the animation that should run when the incorrect key is brought to the box
	/// - important:  this function should be called with `currentlyAnimating` already set to `true`
    private func invalidContactAnimation(forState state:Message3DScene.PaperState) {
        let wait = SKAction.wait(forDuration: IntroScene.invalidPulseTime)
        let questionMark = SKAction.customAction(withDuration: 0) { _, _ in
            InteractiveScene.paperScene.morphToQuestionMark(duration: IntroScene.invalidPulseTime)
        }
        let backToPaper = SKAction.customAction(withDuration: 0) { _, _ in
            state == .encrypted ? InteractiveScene.paperScene.morphToCrypto(duration: InteractiveScene.invalidPulseTime) : InteractiveScene.paperScene.morphToPaper(duration: IntroScene.invalidPulseTime)
        }
        let notAnimating = SKAction.customAction(withDuration: 0) { _, _ in
            self.currentlyAnimating = false
        }
        let invalidContactSequence = SKAction.sequence([questionMark,wait,backToPaper,wait,notAnimating])
        self.messageNode.run(invalidContactSequence)
    }
    
    public override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // update caged key positions if needed
        // position key labels above the keys
        for (key,keyLabel) in keyToKeyLabel {
            if let cage = key.insideCage {
                key.position = CGPoint(x: cage.position.x, y: cage.position.y-10)
            }
            updatePosition(forNode: keyLabel, aboveNode: key)
        }
		updatePosition(forNode: messageLabel, aboveNode: messageNode, by: 45.0)
        // update finger position or exit
        guard let point = currentFingerPosition else { return }
        // determine which character is in range of message
        self.determineCharacterInRangeOfMessage()
        // ignore movement if position is outside scene
        let margin:CGFloat = 10
        if point.x < margin || point.x > self.size.width - margin || point.y < margin || point.y > self.size.height - margin {
            // stop moving keys if the touch is outside the margin
            for moveable in allMoveable {
                moveable.stopMoving(at: point)
            }
        } else {
            for movable in allMoveable {
                movable.updatePositionIfNeeded(to: point)
            }
        }
    }
    
	private func updatePosition(forNode node:SKNode, aboveNode mainNode:SKNode, by amount:CGFloat=30.0) {
        node.position = CGPoint(x: mainNode.position.x, y: mainNode.position.y + amount)
    }
    
    private func determineCharacterInRangeOfMessage() {
        // calculate message position to each character
        for char in allCharacters {
            // use pythagoras to get distance to message
            let x = messageNode.position.x - char.position.x
            let y = messageNode.position.y - char.position.y
            let dist = sqrt(x*x + y*y)
            if dist < 170 {
                self.setCharacterFocusIfNeeded(character: char)
                // exit after this
                return
            }
        }
        // we are not near a character, set none in focus
        self.setNoCharacterFocusIfNeeded()
        self.setNoKeyFocusIfNeeded()
    }
    
    /// sets the focus on a single character, and focuses the possible keys that can be used by them
    private func setCharacterFocusIfNeeded(character:CharacterSprite) {
        guard let nodeName = character.name else { return }
        if let existingFocus = characterInRange {
            guard let existingName = existingFocus.name else { return }
			// only focus on this new character if we are not already focused on them
            guard existingName != nodeName else { return }
        }
        guard let characterType = SceneCharacters(rawValue: nodeName) else { return }
		if InteractiveScene.paperScene.paperState == .unencrypted {
			// update the message shown on the paper (if unencrypted)
			InteractiveScene.paperScene.updateMessageIfUnencrypted(toPerson: characterType)
			// update the text above the message if unencrypted
			self.messageLabel.text = character.labelForMessage
		}
        // set the correct focus on the character and keys
        switch characterType {
        case .alice:
            self.focus(character: aliceCharacter, defocus: [bobCharacter, eveCharacter])
            self.focus(keys: [alicePublicKeyNode, alicePrivateKeyNode, bobPublicKeyNode], defocus: [bobPrivateKeyNode])
			aliceCharacter.run(aliceSound)
        case .bob:
            self.focus(character: bobCharacter, defocus: [aliceCharacter, eveCharacter])
            self.focus(keys: [alicePublicKeyNode, bobPrivateKeyNode, bobPublicKeyNode], defocus: [alicePrivateKeyNode])
			bobCharacter.run(bobSound)
        case .eve:
            self.focus(character: eveCharacter, defocus: [aliceCharacter, bobCharacter])
            self.focus(keys: [alicePublicKeyNode, bobPublicKeyNode], defocus: [alicePrivateKeyNode, bobPrivateKeyNode])
			eveCharacter.run(eveSound)
        }
    }
    
    private func focus(character:CharacterSprite, defocus:[CharacterSprite]) {
		self.noCharactersFocused = false // we are now focused on a character
        self.characterInRange = character
        character.currentState = .inRange
        character.run(fadeUp)
        for other in defocus {
			other.removeAllActions() // remove actions so we don't accidently go back to inrange
            if other.currentState != .waiting {
                other.currentState = .waiting
            }
            other.run(fadeDown)
        }
    }
    
    private func focus(keys:[KeySprite], defocus:[KeySprite]) {
		self.noKeysFocused = false // we are now focused on a certain key
        for key in keys {
            key.run(fadeUp)
            if let label = keyToKeyLabel[key] {
                label.run(fadeUp)
            }
            self.removeKeyFromCage(key: key)
            key.isUserInteractionEnabled = false
        }
        for key in defocus {
            key.run(fadeDown)
            if let label = keyToKeyLabel[key] {
                label.run(fadeDown)
            }
            self.putKeyInsideCorrectCageIfNeeded(key: key)
            key.isUserInteractionEnabled = true
        }
    }
    
    private func setNoCharacterFocusIfNeeded() {
		// check that we are not already defocused from all characters (for efficiency)
		guard !self.noCharactersFocused else { return }
		self.noCharactersFocused = true // we are now not focused on a character
        // set our local variable to be nil
        self.characterInRange = nil
        // no characters in range, set all waiting with full alpha
        for character in allCharacters {
			character.removeAllActions() // remove actions so we don't accidently go back to inrange
            if character.currentState != .waiting {
                character.currentState = .waiting
            }
            character.run(fadeUp)
        }
    }
    
    private func setNoKeyFocusIfNeeded() {
		// check that we are not already defocused from all keys (for efficiency)
		guard !self.noKeysFocused else { return }
		self.noKeysFocused = true
		// defocus all the keys if we need to
        for (key,keyLabel) in keyToKeyLabel {
            key.run(fadeDown)
            keyLabel.run(fadeDown)
            key.isUserInteractionEnabled = true
            // put the private keys in a cage
            self.putKeyInsideCorrectCageIfNeeded(key: key)
        }
    }
    
    private func putKeyInsideCorrectCageIfNeeded(key:KeySprite) {
        if key === alicePrivateKeyNode {
            self.putInsideCage(key: key, cage: self.aliceCage)
        } else if key === bobPrivateKeyNode {
            self.putInsideCage(key: key, cage: self.bobCage)
        }
    }
	
    private func putInsideCage(key:KeySprite, cage:CageSprite) {
        guard key.insideCage == nil else { return }
        key.insideCage = cage
        key.removeAction(forKey: "removingFromCage")
        key.removeAction(forKey: "puttingInCage")
        key.physicsBody?.isDynamic = false
        key.physicsBody?.collisionBitMask = PhysicsCategory.all ^ (PhysicsCategory.box | PhysicsCategory.chainLink)
        let moveToCage = SKAction.move(to: cage.position, duration: 0.3)
        moveToCage.timingMode = .easeOut
        key.run(moveToCage, withKey: "puttingInCage")
    }
    
    private func removeKeyFromCage(key:KeySprite) {
        guard let _ = key.insideCage else { return }
        key.insideCage = nil
        key.removeAction(forKey: "puttingInCage")
        key.removeAction(forKey: "removingFromCage")
        key.physicsBody?.isDynamic = true
        let enableFullCollisions = SKAction.customAction(withDuration: 0) { (_, _) in
            // ensure that when the block is run we are still outside of the cage
            guard key.insideCage == nil else { return }
            key.physicsBody?.collisionBitMask = PhysicsCategory.all ^ (PhysicsCategory.box)
        }
        key.run(enableFullCollisions, withKey: "removingFromCage")
    }
}
