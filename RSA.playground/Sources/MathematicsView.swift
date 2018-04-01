//
//  MathematicsView.swift
//  wwdc-2018
//
//  Created by Bradley Mackey on 20/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

public final class MathematicsView: SKView, MathematicsSceneInformationDelegate {
	
	/// animates the information overlay when labels are tapped
	private var informationPaneAnimator:UIViewPropertyAnimator!
	
	private lazy var blurView:UIVisualEffectView = {
		let view = UIVisualEffectView(frame: self.frame)
		view.effect = nil
		return view
	}()
	
	/// the big bold title label that is displayed in the information view
	private lazy var informationTitleLabel:UILabel = {
		let labelFrame = CGRect(x: 40, y: 25, width: (self.frame.width/2)-60, height: 50)
		let label = UILabel(frame: labelFrame)
		label.font = UIFont.boldSystemFont(ofSize: 32)
		label.numberOfLines = 0
		label.textColor = .white
		return label
	}()
	
	/// the detail message label that is displayed in the information view
	private lazy var informationDetailLabel:UILabel = {
		let labelFrame = CGRect(x: 30, y: 55, width: (self.frame.width/2)-60, height: self.frame.height-400)
		let label = UILabel(frame: labelFrame)
		label.font = UIFont.systemFont(ofSize: 20)
		label.textColor = .white
		label.numberOfLines = 0
		return label
	}()
	
	/// the message that tells people to drag down to dismiss the message
	private lazy var dismissLabel:UILabel = {
		let labelFrame = CGRect(x: 0, y: self.frame.height-335, width: self.frame.width/2, height: 24)
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
		let viewFrame = CGRect(x: self.frame.width/4, y: self.frame.height, width: self.frame.width/2, height: self.frame.height-300)
		let view = UIView(frame: viewFrame)
		view.backgroundColor = #colorLiteral(red: 0.6379951485, green: 0.6427444434, blue: 0.6216148005, alpha: 1)
		// only mask the corners at the top of the view
		view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
		let recogniser = UIPanGestureRecognizer(target: self, action: #selector(MathematicsView.handlePan(_:)))
		view.addGestureRecognizer(recogniser)
		// add the subviews to the pane
		view.addSubview(informationTitleLabel)
		view.addSubview(informationDetailLabel)
		view.addSubview(dismissLabel)
		return view
	}()
	
	override public init(frame: CGRect) {
		super.init(frame: frame)
		let mathematicsScene = MathematicsScene(size: self.frame.size)
		mathematicsScene.informationDelegate = self
		// Set the scale mode to scale to fit the window
		mathematicsScene.scaleMode = .aspectFill
		// Present the scene
		self.presentScene(mathematicsScene)
		// add the other views that enable the information style view
		self.addSubview(blurView)
		self.addSubview(informationView)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func presentInformationPopup(title: String, message: String) {
		// update the label text on the panels
		informationTitleLabel.text = title
		informationDetailLabel.text = message
		// cancel any animation that may currently be underway
		self.cancelPriorAnimationIfNeeded()
		// animate upwards
		informationPaneAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeOut) {
			self.informationView.frame = CGRect(x: self.frame.width/4, y: 300, width: self.frame.width/2, height: self.frame.height-300)
			self.informationView.layer.cornerRadius = 50
			self.blurView.effect = UIBlurEffect(style: .light)
			// make sure the user cannot tap other scene elements
			self.scene?.isUserInteractionEnabled = false
		}
		informationPaneAnimator.startAnimation()
	}
	
	@objc public func handlePan(_ recogniser:UIPanGestureRecognizer) {
		switch recogniser.state {
		case .began:
			// cancel and restart animation when user drags
			self.cancelPriorAnimationIfNeeded()
			informationPaneAnimator = UIViewPropertyAnimator(duration: 0.4, curve: .easeOut) {
				self.informationView.frame = CGRect(x: self.frame.width/4, y: self.frame.height, width: self.frame.width/2, height: self.frame.height-300)
				self.informationView.layer.cornerRadius = 0
				self.blurView.effect = nil
				// ensure that the scene is fully interactive again
				self.scene?.isUserInteractionEnabled = true
			}
			informationPaneAnimator.pauseAnimation()
		case .changed:
			// move to the new finger position
			let translation = recogniser.translation(in: self)
			informationPaneAnimator.fractionComplete = translation.y / 400
		case .ended:
			if informationPaneAnimator.fractionComplete == 0.0 {
				// we clearly don't want to do the animation, stop here
				self.cancelPriorAnimationIfNeeded()
				// regenerate the blur effect (to prevent a weird glitch where it won't go away after we stop back at the top)
				self.blurView.effect = UIBlurEffect(style: .light)
			} else {
				// continue animation when user lets go of display
				informationPaneAnimator.continueAnimation(withTimingParameters: nil, durationFactor: 0.5)
			}
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
