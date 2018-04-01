//
//  DragBoxState.swift
//  wwdc-2018
//
//  Created by Bradley Mackey on 31/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit

/// the base class that represents the possible states that the draggable message box in the interactive scene can be
public class MessageState: GKState {
	
	// MARK: - Properties
	
	/// the message that we can drag around or rotate
	public unowned let message:Message3DNode
	
	/// the point where the key started moving, so we can tell it where to move initially
	public var startMovingPoint:CGPoint?
	
	// MARK: - Lifecycle
	
	public init(message:Message3DNode) {
		self.message = message
	}
	
}
