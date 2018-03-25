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
    
    // MARK: Constants
	
	/// the amount of time that we pause on the character when they do an animation
    public static var changeAnimationPauseTime:TimeInterval = 1.1
    
    // MARK: Instance
	
	/// the state that the character is currently in
	/// - note: updates the state of the character and the label text
    public var currentState:State {
        get {
            return _currentState
        }
        set {
            _currentState = newValue
            self.text = self.textForCurrentState
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
        self.physicsBody = CharacterSprite.physicsBody(ofRadius: self.frame.size.width/2)
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
        nameLabel.fontSize = 21
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
    
    public func successAnimation() {
        self.changeAnimation(to: self.success)
    }
    
    public func failAnimation() {
        self.changeAnimation(to: self.fail)
    }
    
    private func changeAnimation(to text:String) {
		// only perform animation if we are not currently animating
		guard !self.hasActions() else { return }
        let change = SKAction.customAction(withDuration: 0) { (_, _) in
            self.text = text
        }
        let wait = SKAction.wait(forDuration: CharacterSprite.changeAnimationPauseTime)
        let changeToInRange = SKAction.customAction(withDuration: 0) { (_, _) in
            self.text = self.inRange
        }
        let sequence = SKAction.sequence([change,wait,changeToInRange])
        self.run(sequence)
    }
	
}
