//
//  InteractiveView.swift
//  wwdc-2018
//
//  Created by Bradley Mackey on 20/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

/// the view that holds the interactive scene
public final class InteractiveView: SKView {
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		let interactiveScene = InteractiveScene(size: self.frame.size)
		// Set the scale mode to scale to fit the window
		interactiveScene.scaleMode = .aspectFill
		// Present the scene
		self.presentScene(interactiveScene)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
}
