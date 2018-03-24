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
	
	// MARK: - Properties
	
	// MARK: Constants
	
	// MARK: Instance Variables
	
	/*
	
		FULLY FREE-FORM

		PRIVATE KEYS ARE ATTACHED TO EACH CHARACTER WITH A CHAIN
		PUBLIC KEYS ARE FREE FLOATING
	
		THE MESSAGE CAN ONLY BE DRAGGED TO TARGET ZONES ABOVE THE CHARACTERS (where it will snap and remain in that position)

	*/
	
	public static var paperScene = Message3DScene(message: "Another message. Go ahead and encrypt me.")
	
	private lazy var messageNode:Message3DNode = {
		let sceneSize = CGSize(width: 170, height: 170)
		let sceneNode = Message3DNode(viewportSize: sceneSize, messageScene: InteractiveScene.paperScene)
		sceneNode.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
		sceneNode.name = "messageNode"
		return sceneNode
	}()
	
	private lazy var aliceCharacter:CharacterSprite = {
        let alice = CharacterSprite(characterName: "Alice", waiting: "👩🏽‍💻", success: "🙆🏽‍♀️", fail: "🤦🏽‍♀️")
		alice.name = "aliceCharacter"
        alice.position = CGPoint(x: self.size.width/4, y: 40)
		return alice
	}()
	
	private lazy var bobCharacter:CharacterSprite = {
		let bob = CharacterSprite(characterName: "Bob", waiting: "👨🏼‍💻", success: "🙆🏼‍♂️", fail: "🤦🏼‍♂️")
		bob.name = "bobCharacter"
        bob.position = CGPoint(x: 3*self.size.width/4, y: 40)
		return bob
	}()
	
	private lazy var eveCharacter:CharacterSprite = {
		let eve = CharacterSprite(characterName: "Eve", waiting: "👩🏻‍💻", success: "🙆🏻‍♀️", fail: "🤦🏻‍♀️")
		eve.name = "eveCharacter"
        eve.position = CGPoint(x: 2*self.size.width/4, y: 2*self.size.height/3)
		return eve
	}()
	
	private lazy var alicePublicKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.publicColor, owner: .alice, type: .pub)
		keySprite.name = "alicePublicKeyNode"
		keySprite.position = CGPoint(x: 3*self.size.width/4, y: self.size.height/4)
		return keySprite
	}()
	
	private lazy var alicePrivateKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.privateColor, owner: .alice, type: .priv)
		keySprite.name = "alicePrivateKeyNode"
		keySprite.position = CGPoint(x: 3*self.size.width/4, y: self.size.height/4)
		return keySprite
	}()
	
	private lazy var bobPublicKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.publicColor, owner: .bob, type: .pub)
		keySprite.name = "bobPublicKeyNode"
		keySprite.position = CGPoint(x: 3*self.size.width/4, y: self.size.height/4)
		return keySprite
	}()
	
	private lazy var bobPrivateKeyNode:KeySprite = {
		let keySprite = KeySprite(texture: RSAScene.keyTexture, color: IntroScene.privateColor, owner: .bob, type: .priv)
		keySprite.name = "bobPrivateKeyNode"
		keySprite.position = CGPoint(x: 3*self.size.width/4, y: self.size.height/4)
		return keySprite
	}()
    
    /// convenience property to get all characters
    private lazy var allCharacters:[CharacterSprite] = {
        return [aliceCharacter, bobCharacter, eveCharacter]
    }()
    
    /// convenience property to get all keys
    private lazy var allKeys:[KeySprite] = {
        return [alicePublicKeyNode, alicePrivateKeyNode, bobPublicKeyNode, bobPrivateKeyNode]
    }()
	
	// MARK: - Setup
	
	public override func sceneDidLoad() {
		super.sceneDidLoad()
		self.backgroundColor = .white
        self.addNodesToScene()
	}
    
    private func addNodesToScene() {
        self.allCharacters.forEach {
            self.addChild($0)
        }
        self.allKeys.forEach {
            self.addChild($0)
        }
        self.addChild(messageNode)
    }
	
	// MARK: - Methods
	
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
        default:
            return
        }
	}
	
	override public func touchMoved(toPoint point: CGPoint) {
		super.touchMoved(toPoint: point)
	}
	
	override public func touchUp(atPoint point: CGPoint) {
		super.touchUp(atPoint: point)
        self.allKeys.forEach {
            $0.stopMoving(at: point)
        }
	}
	
	public override func bodyContact(firstBody: SKPhysicsBody, secondBody: SKPhysicsBody) {
		super.bodyContact(firstBody: firstBody, secondBody: secondBody)
	}
    
    public override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // Called before each frame is rendered
        if let point = currentFingerPosition {
            // ignore movement if position is outside scene
            let margin:CGFloat = 10
            if point.x < margin || point.x > self.size.width - margin || point.y < margin || point.y > self.size.height - margin {
                // stop moving keys if the touch is outside the margin
                self.allKeys.forEach {
                    $0.stopMoving(at: point)
                }
            } else {
                self.allKeys.forEach {
                    $0.updatePositionIfNeeded(to: point)
                }
            }
        }
    }
	
}
