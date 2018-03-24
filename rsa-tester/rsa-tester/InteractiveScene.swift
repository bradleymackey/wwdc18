//
//  InteractiveScene.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 22/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

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
    
    public static var fadedDown:CGFloat = 0.15
    public static var fadeTime:TimeInterval = 0.2
    
    public static var aliceMessage = "Hello world."
    public static var bobMessage = "This is a test."
    public static var eveMessage = "I am a 1337 hacker!!"
	
	// MARK: Instance Variables
	
	public static var paperScene = Message3DScene(message: "Another message. Go ahead and encrypt me.")
    
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
		let sceneSize = CGSize(width: 150, height: 150)
		let sceneNode = Message3DNode(viewportSize: sceneSize, messageScene: InteractiveScene.paperScene)
		sceneNode.position = CGPoint(x: self.size.width/2, y: self.size.height/3)
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
        eve.position = CGPoint(x: 2*self.size.width/4, y: 2*self.size.height/3)
		return eve
	}()
	
	private lazy var alicePublicKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.publicColor, owner: .alice, type: .pub)
		keySprite.name = "alicePublicKeyNode"
		keySprite.position = CGPoint(x: (self.size.width/4)+20, y: self.size.height/4)
		return keySprite
	}()
	
	private lazy var alicePrivateKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.privateColor, owner: .alice, type: .priv)
		keySprite.name = "alicePrivateKeyNode"
		keySprite.position = CGPoint(x: (self.size.width/4)-20, y: self.size.height/4)
		return keySprite
	}()
	
	private lazy var bobPublicKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.publicColor, owner: .bob, type: .pub)
		keySprite.name = "bobPublicKeyNode"
		keySprite.position = CGPoint(x: (3*self.size.width/4)-20, y: self.size.height/4)
		return keySprite
	}()
	
	private lazy var bobPrivateKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.privateColor, owner: .bob, type: .priv)
		keySprite.name = "bobPrivateKeyNode"
		keySprite.position = CGPoint(x: (3*self.size.width/4)+20, y: self.size.height/4)
		return keySprite
	}()
    
    private lazy var alicePublicLabel:SKLabelNode = {
        let label = InteractiveScene.keyLabel(text: "Alice\nPublic")
        label.position = CGPoint(x: alicePublicKeyNode.position.x, y: alicePublicKeyNode.position.y + 40)
        return label
    }()
    
    private lazy var alicePrivateLabel:SKLabelNode = {
        let label = InteractiveScene.keyLabel(text: "Alice\nPrivate")
        label.position = CGPoint(x: alicePrivateKeyNode.position.x, y: alicePrivateKeyNode.position.y + 40)
        return label
    }()
    
    private lazy var bobPublicLabel:SKLabelNode = {
        let label = InteractiveScene.keyLabel(text: "Bob\nPublic")
        label.position = CGPoint(x: bobPublicKeyNode.position.x, y: bobPublicKeyNode.position.y + 40)
        return label
    }()
    
    private lazy var bobPrivateLabel:SKLabelNode = {
        let label = InteractiveScene.keyLabel(text: "Bob\nPrivate")
        label.position = CGPoint(x: bobPrivateKeyNode.position.x, y: bobPrivateKeyNode.position.y + 40)
        return label
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
    
    /// the character that is currently in range of the message
    private weak var characterInRange:CharacterSprite?
    /// whether the box animation is currently taking place
    private var currentlyAnimating = false
	
	// MARK: - Setup
	
	public override func sceneDidLoad() {
		super.sceneDidLoad()
		self.backgroundColor = .white
        self.addNodesToScene()
        self.setNoCharacterFocus()
        self.setNoKeyFocus()
	}
    
    private func addNodesToScene() {
        // characters
        for character in allCharacters {
            self.addChild(character)
        }
        // the 3d message
        self.addChild(messageNode)
        // keys and labels
        for (key,keyLabel) in keyToKeyLabel {
            // add the key before the label so it can be positioned above it
            self.addChild(key)
            self.addChild(keyLabel)
        }
    }
	
	// MARK: - Methods
    
    private class func keyLabel(text:String) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: "SanFransico")
        label.text = text
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 2
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
            self.alicePublicContact()
        case PhysicsCategory.privateKeyA:
            return
        case PhysicsCategory.publicKeyB:
            return
        case PhysicsCategory.privateKeyB:
            return
        default:
            return
        }
	}
    
    private func alicePublicContact() {
        
    }
    
    private func alicePrivateContact() {
        
    }
    
    private func bobPublicContact() {
        
    }
    
    private func bobPrivateContact() {
        
    }
    
    public override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // position key labels above the keys
        for (key,keyLabel) in keyToKeyLabel {
            updatePosition(forNode: keyLabel, aboveNode: key)
        }
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
    
    private func updatePosition(forNode node:SKNode, aboveNode mainNode:SKNode) {
        node.position = CGPoint(x: mainNode.position.x, y: mainNode.position.y + 40)
    }
    
    private func determineCharacterInRangeOfMessage() {
        // calculate message position to each character
        for char in allCharacters {
            // use pythagoras to get distance to message
            let x = messageNode.position.x - char.position.x
            let y = messageNode.position.y - char.position.y
            let dist = sqrt(x*x + y*y)
            if dist < 170 {
                self.setCharacterFocus(character: char)
                // exit after this
                return
            }
        }
        // we are not near a character, set none in focus
        self.setNoCharacterFocus()
        self.setNoKeyFocus()
    }
    
    /// sets the focus on a single character, and focuses the possible keys that can be used by them
    private func setCharacterFocus(character:CharacterSprite) {
        guard let nodeName = character.name else { return }
        guard let character = SceneCharacters(rawValue: nodeName) else { return }
        // update the message shown on the paper (if unencrypted)
        DispatchQueue.global(qos: .background).async {
            InteractiveScene.paperScene.updateMessageIfUnencrypted(toPerson: character)
        }
        // set the correct focus on the character and keys
        switch character {
        case .alice:
            self.focus(character: aliceCharacter, defocus: [bobCharacter, eveCharacter])
            self.focus(keys: [alicePublicKeyNode, alicePrivateKeyNode, bobPublicKeyNode], defocus: [bobPrivateKeyNode])
        case .bob:
            self.focus(character: bobCharacter, defocus: [aliceCharacter, eveCharacter])
            self.focus(keys: [alicePublicKeyNode, bobPrivateKeyNode, bobPublicKeyNode], defocus: [alicePrivateKeyNode])
        case .eve:
            self.focus(character: eveCharacter, defocus: [aliceCharacter, bobCharacter])
            self.focus(keys: [alicePublicKeyNode, bobPublicKeyNode], defocus: [alicePrivateKeyNode, bobPrivateKeyNode])
           
        }
    }
    
    private func focus(character:CharacterSprite, defocus:[CharacterSprite]) {
        self.characterInRange = character
        character.currentState = .inRange
        character.run(fadeUp)
        for other in defocus {
            if other.currentState != .waiting {
                other.currentState = .waiting
            }
            other.run(fadeDown)
        }
    }
    
    private func focus(keys:[KeySprite], defocus:[KeySprite]) {
        for key in keys {
            key.run(fadeUp)
            if let label = keyToKeyLabel[key] {
                label.run(fadeUp)
            }
            key.isUserInteractionEnabled = false
        }
        for key in defocus {
            key.run(fadeDown)
            if let label = keyToKeyLabel[key] {
                label.run(fadeDown)
            }
            key.isUserInteractionEnabled = true
        }
    }
    
    private func setNoCharacterFocus() {
        // no characters in range, set all waiting with full alpha
        for character in allCharacters {
            if character.currentState != .waiting {
                character.currentState = .waiting
            }
            character.run(fadeUp)
        }
    }
    
    private func setNoKeyFocus() {
        for (key,keyLabel) in keyToKeyLabel {
            key.run(fadeDown)
            keyLabel.run(fadeDown)
            key.isUserInteractionEnabled = true
        }
    }
	
}
