//
//  SceneAnimatingState.swift
//  wwdc-2018
//
//  Created by Bradley Mackey on 30/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import GameplayKit

public final class SceneAnimatingState: SceneState {
	public override func isValidNextState(_ stateClass: AnyClass) -> Bool {
		// valid if next state is wait
		return stateClass is SceneWaitState.Type
	}
}
