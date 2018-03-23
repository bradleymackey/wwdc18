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
	
	/// animates the information overlay when labels are tapped
	private var informationPaneAnimator:UIViewPropertyAnimator!
	
	private lazy var blurView:UIVisualEffectView = {
		let view = UIVisualEffectView(frame: self.view.frame)
		view.effect = nil
		return view
	}()
	
	/// the big bold title label that is displayed in the information view
	private lazy var informationTitleLabel:UILabel = {
		let labelFrame = CGRect(x: 30, y: 15, width: self.view.frame.width-60, height: 50)
		let label = UILabel(frame: labelFrame)
		label.font = UIFont.boldSystemFont(ofSize: 32)
		label.numberOfLines = 0
		label.textColor = .white
		return label
	}()
	
	/// the detail message label that is displayed in the information view
	private lazy var informationDetailLabel:UILabel = {
		let labelFrame = CGRect(x: 30, y: 55, width: self.view.frame.width-60, height: self.view.frame.height-300)
		let label = UILabel(frame: labelFrame)
		label.font = UIFont.systemFont(ofSize: 20)
		label.textColor = .white
		label.numberOfLines = 0
		return label
	}()
	
	/// the message that tells people to drag down to dismiss the message
	private lazy var dismissLabel:UILabel = {
		let labelFrame = CGRect(x: 0, y: self.view.frame.height-235, width: self.view.frame.width, height: 24)
		let label = UILabel(frame: labelFrame)
		label.text = "Drag down to dismiss"
		label.font = UIFont.systemFont(ofSize: 15)
		label.textColor = .white
		label.textAlignment = .center
		return label
	}()
	
	/// the view that diplays the information about the label that was tapped
	private lazy var informationView:UIView = {
		// make the view a bit shorter than the height of the full view and set it offscreen initially.
		let viewFrame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height-200)
		let view = UIView(frame: viewFrame)
		view.backgroundColor = #colorLiteral(red: 0.6379951485, green: 0.6427444434, blue: 0.6216148005, alpha: 1)
		// only mask the corners at the top of the view
		view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		let recogniser = UIPanGestureRecognizer(target: self, action: #selector(GameViewController.handlePan(_:)))
		view.addGestureRecognizer(recogniser)
		// add the subviews to the pane
		view.addSubview(informationTitleLabel)
		view.addSubview(informationDetailLabel)
		view.addSubview(dismissLabel)
		return view
	}()
	
	private var scene:InteractiveScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
		if let view = self.view as! SKView? {
			
			
//			scene = IntroScene(size: view.bounds.size)
//			scene.informationDelegate = self
			
			scene = InteractiveScene(size: view.bounds.size)
			
			
			// Set the scale mode to scale to fit the window
			scene.scaleMode = .aspectFill
			
			// Present the scene
			view.presentScene(scene)
		
			//view.ignoresSiblingOrder = true
			
			view.showsFPS = true
			view.showsNodeCount = true
		}
		
		// add the other views that enable the information style view
		self.view.addSubview(blurView)
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
		// update the label text on the panels
		informationTitleLabel.text = title
		informationDetailLabel.text = message
		// cancel any animation that may currently be underway
		self.cancelPriorAnimationIfNeeded()
		// animate upwards
		informationPaneAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeOut) {
			self.informationView.frame = CGRect(x: 0, y: 200, width: self.view.frame.width, height: self.view.frame.height-200)
			self.informationView.layer.cornerRadius = 50
			self.blurView.effect = UIBlurEffect(style: .light)
			// make sure the user cannot tap other scene elements
			self.scene.isUserInteractionEnabled = false
		}
		informationPaneAnimator.startAnimation()
	}
	
	@objc func handlePan(_ recogniser:UIPanGestureRecognizer) {
		switch recogniser.state {
		case .began:
			// cancel and restart animation when user drags
			self.cancelPriorAnimationIfNeeded()
			informationPaneAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeOut) {
				self.informationView.frame = CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: self.view.frame.height-200)
				self.informationView.layer.cornerRadius = 0
				self.blurView.effect = nil
				// ensure that the scene is fully interactive again
				self.scene.isUserInteractionEnabled = true
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
			// ignore other gesture events
			return
		}
	}
	
	private func cancelPriorAnimationIfNeeded() {
		// immediately stop any animation currently underway, and
		informationPaneAnimator?.stopAnimation(true)
		informationPaneAnimator?.finishAnimation(at: .current)
	}
}
