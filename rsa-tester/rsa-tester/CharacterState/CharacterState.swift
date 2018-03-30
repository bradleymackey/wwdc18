//
//  CharacterState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit

/// the base class for the possible states that a character can be in
public class CharacterState: GKState {
	
	/// the text that the character should display in this given state
	public let text:String
	public let character:CharacterSprite
	
	public init(character:CharacterSprite, text:String) {
		self.text = text
		self.character = character
	}
	
	public override func didEnter(from previousState: GKState?) {
		super.didEnter(from: previousState)
		// update the text of the character
		self.character.text = text
	}
}
