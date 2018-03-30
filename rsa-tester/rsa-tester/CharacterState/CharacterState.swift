//
//  CharacterState.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit

public class CharacterState: GKState {
	/// the text that the character should display in this given state
	public let text:String
	
	public init(text:String) {
		self.text = text
	}
}
