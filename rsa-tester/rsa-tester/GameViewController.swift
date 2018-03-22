//
//  GameViewController.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 20/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

final class GameViewController: UIViewController, IntroSceneInformationDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
		if let view = self.view as! SKView? {
			// Load the SKScene from 'GameScene.sks'
			let scene = IntroScene(size: view.bounds.size)
			scene.informationDelegate = self
			// Set the scale mode to scale to fit the window
			scene.scaleMode = .aspectFill
			
			// Present the scene
			view.presentScene(scene)
		
			//view.ignoresSiblingOrder = true
			
			view.showsFPS = true
			view.showsNodeCount = true
		}
    }

    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
	
	func presentInformationPopup(title: String, message: String) {
		print(title)
		print(message)
	}
}
