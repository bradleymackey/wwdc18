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
	
	var informationPaneAnimator:UIViewPropertyAnimator!
	
	/// the big bold title label that is displayed in the information view
	private lazy var informationTitleLabel:UILabel = {
		let label = UILabel(frame: .zero)
		return label
	}()
	
	/// the detail message label that is displayed in the information view
	private lazy var informationDetailLabel:UILabel = {
		let label = UILabel(frame: .zero)
		return label
	}()
	
	/// the view that diplays the information about the label that was tapped
	private lazy var informationView:UIView = {
		// make the view a bit shorter than the height of the full view and set it offscreen initially.
		let viewFrame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height-100)
		let view = UIView(frame: viewFrame)
		view.backgroundColor = .blue
		// only mask the corners at the top of the view
		view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		let recogniser = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.handlePan(_:)))
		view.addGestureRecognizer(recogniser)
		return view
	}()

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
		
		self.view.addSubview(informationView)
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
		self.cancelAnimationIfNeeded()
		// animate upwards
		informationPaneAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
			self.informationView.frame = CGRect(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.height-100)
			self.informationView.layer.cornerRadius = 50
		}
		informationPaneAnimator.startAnimation()
	}
	
	@objc func handlePan(_ recogniser:UIPanGestureRecognizer) {
		switch recogniser.state {
		case .began:
			// cancel and restart animation when user drags
			self.cancelAnimationIfNeeded()
			informationPaneAnimator = UIViewPropertyAnimator(duration: 0.5, curve: .easeOut) {
				self.informationView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height-100)
				self.informationView.layer.cornerRadius = 0
			}
			informationPaneAnimator.pauseAnimation()
		case .changed:
			// move to the new finger position
			let translation = recogniser.translation(in: self.view)
			informationPaneAnimator.fractionComplete = translation.y / 400
		case .ended:
			// continue animation when user lets go of display
			informationPaneAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0.5)
		case .possible, .cancelled, .failed:
			return
		}
	}
	
	private func cancelAnimationIfNeeded() {
		// immediately stop any animation currently underway, and
		informationPaneAnimator?.stopAnimation(true)
		informationPaneAnimator?.finishAnimation(at: .current)
	}
}
