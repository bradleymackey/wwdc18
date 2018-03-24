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
		case acting
		case success
		case fail
	}
	
	// MARK: - Properties
	
	/// the state that the character is currently in
	/// - note: we are initially waiting
	public var currentState = State.waiting
	/// the expression the character gives when waiting
	private let waiting:String
	/// the expression the character gives when encrypting a message or reading
	private let acting:String
	/// the expression after a success event
	private let success:String
	/// the expression after a fail event
	private let fail:String
	
	private var textForCurrentState:String {
		switch self.currentState {
		case .waiting:
			return self.waiting
		case .acting:
			return self.acting
		case .success:
			return self.success
		case .fail:
			return self.fail
		}
	}
	
	// MARK: - Setup
	
	public init(waiting:String, acting:String, success:String, fail:String) {
		self.waiting = waiting
		self.acting = acting
		self.success = success
		self.fail = fail
		super.init(fontNamed: "Helvetica") // font does not matter, we are using emoji
		self.text = self.waiting // we are initially waiting
		self.setupLabelProperties()
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Methods
	
	private class func physicsBody() -> SKPhysicsBody {
		let body = SKPhysicsBody
	}
	
	/// sets up properties of the label
	private func setupLabelProperties() {
		self.fontSize = 30
		self.horizontalAlignmentMode = .center
		self.verticalAlignmentMode = .center
	}
	
	public func setState(to state:State) {
		self.currentState = state
		self.text = self.textForCurrentState
	}
	
}
