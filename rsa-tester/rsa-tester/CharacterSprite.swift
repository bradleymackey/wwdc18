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
	
	public enum State {
		case waiting
		case acting
	}
	
	/// the state that the character is currently in
	/// - note: we are initially waiting
	public var currentState = State.waiting
	/// the expression the character gives when waiting
	private let waiting:String
	/// the expression the character gives when encrypting a message or reading
	private let acting:String
	
	public init(waiting:String, acting:String) {
		self.waiting = waiting
		self.acting = acting
		// font does not matter, we are using emoji
		super.init(fontNamed: "Helvetica")
		// we are initially waiting
		self.text = self.waiting
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func setState(to state:State) {
		self.currentState = state
		switch state {
		case .waiting:
			self.text = self.waiting
		case .acting:
			self.text = self.acting
		}
	}
	
}
