//
//  CharacterSprite.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 23/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

/// an emoji character within the interactive scene
public final class CharacterSprite: SKLabelNode {
	
	/// the possible states that a character can be in
	public enum State {
		case waiting
        case inRange
		case success
		case fail
	}
	
	// MARK: - Properties
	
	/// the state that the character is currently in
	/// - note: we are initially waiting
    public var currentState:State {
        get {
            return _currentState
        }
        set {
            self.text = self.textForCurrentState
            _currentState = newValue
        }
    }
    private var _currentState = State.waiting
    /// the name of the character
    public let characterName:String
	/// the expression the character gives when waiting
	private let waiting:String
    /// the expression when the message is in range of a character
    private let inRange:String
	/// the expression after a success event
	private let success:String
	/// the expression after a fail event
	private let fail:String
	
	private var textForCurrentState:String {
		switch self.currentState {
		case .waiting:
			return self.waiting
        case .inRange:
            return self.inRange
		case .success:
			return self.success
		case .fail:
			return self.fail
		}
	}
	
	// MARK: - Setup
	
    public init(characterName:String, waiting:String, inRange:String, success:String, fail:String) {
        self.characterName = characterName
		self.waiting = waiting
        self.inRange = inRange
		self.success = success
		self.fail = fail
		super.init()
		self.setup() // perform the setup of the character
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Methods
    
    private func setup() {
        self.text = self.waiting // we are initially waiting
        self.setupLabelProperties()
        self.physicsBody = CharacterSprite.physicsBody(ofRadius: 2*self.frame.size.width/3)
        self.addNameAboveCharacter()
    }
	
    private class func physicsBody(ofRadius radius:CGFloat) -> SKPhysicsBody {
		let body = SKPhysicsBody(circleOfRadius: radius)
        body.categoryBitMask = PhysicsCategory.character
        body.contactTestBitMask = PhysicsCategory.none
        body.collisionBitMask = PhysicsCategory.all ^ PhysicsCategory.boundry // collide with all but boundry
        body.allowsRotation = false
        body.pinned = true // the character is fixed to the canvas
        return body
	}
    
    private func addNameAboveCharacter() {
        let nameLabel = SKLabelNode(fontNamed: "San-Francisco")
        nameLabel.text = self.characterName
        nameLabel.fontSize = 19
        nameLabel.fontColor = .black
        nameLabel.position = CGPoint(x: 0, y: 70)
        nameLabel.horizontalAlignmentMode = .center
        nameLabel.verticalAlignmentMode = .center
        self.addChild(nameLabel)
    }
	
	/// sets up properties of the label
	private func setupLabelProperties() {
		self.fontSize = 90
		self.horizontalAlignmentMode = .center
		self.verticalAlignmentMode = .center
	}
	
}
