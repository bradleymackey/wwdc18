//
//  CharacterSprite.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 23/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit
import GameplayKit

/// an emoji character within the interactive scene
public final class CharacterSprite: SKLabelNode {
	
	// MARK: - Properties
    
    // MARK: Constants
	
	/// the amount of time that we pause on the character when they do an animation
    public static var changeAnimationPauseTime:TimeInterval = 1.1
    
    // MARK: Instance
	
	public var labelForMessage:String {
		return characterName + "'s Message"
	}
	
	public var lockedByMessage:String {
		return "🔒 by " + characterName + "'s Key"
	}
	
    /// the name of the character
    public let characterName:String
	/// the expression the character gives when waiting
	public let waiting:String
    /// the expression when the message is in range of a character
    public let inRange:String
	/// the expression after a success event
	public let success:String
	/// the expression after a fail event
	public let fail:String
	
	/// the states that a character can be in
	public var characterStates:[CharacterState] {
		return [CharacterWaitingState(character: self, text: self.waiting),
				CharacterWaitingInactiveState(character: self, text: self.waiting),
				CharacterFailState(character: self, text: self.fail),
				CharacterSuccessState(character: self, text: self.success),
				CharacterInRangeState(character: self, text: self.inRange)]
	}
	
	/// state machine to manage state transitions
	public lazy var stateMachine = GKStateMachine(states: self.characterStates)
	
	// MARK: - Setup
	
    required public init(characterName:String, waiting:String, inRange:String, success:String, fail:String) {
        self.characterName = characterName
		self.waiting = waiting
        self.inRange = inRange
		self.success = success
		self.fail = fail
		super.init()
		self.setup()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Methods
    
    private func setup() {
        self.stateMachine.enter(CharacterWaitingState.self) // we are initially waiting
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
		body.isDynamic = false
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
	
	private func changeAnimationIfIdle(brieflyTo state: AnyClass) {
		// only perform animation if we are not currently animating
		// only perform animation if we are in the 'inRange' state
		guard !self.hasActions(), let currentState = stateMachine.currentState, currentState.isKind(of: CharacterInRangeState.self) else { return }
		let change = SKAction.customAction(withDuration: 0) { (_, _) in
			self.stateMachine.enter(state.self)
		}
		let wait = SKAction.wait(forDuration: CharacterSprite.changeAnimationPauseTime)
		let changeToInRange = SKAction.customAction(withDuration: 0) { (_, _) in
			self.stateMachine.enter(CharacterInRangeState.self)
		}
		let sequence = SKAction.sequence([change,wait,changeToInRange])
		self.run(sequence)
	}
    
    public func successAnimation() {
        self.changeAnimationIfIdle(brieflyTo: CharacterSuccessState.self)
    }
    
    public func failAnimation() {
        self.changeAnimationIfIdle(brieflyTo: CharacterFailState.self)
    }
	
}
