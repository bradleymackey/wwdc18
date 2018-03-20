//
//  Message3DScene.swift
//  nothing
//
//  Created by Bradley Mackey on 19/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SceneKit

fileprivate extension UIImage {
	/// generates a UIImage from a CALayer
	class func image(from layer: CALayer) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(layer.bounds.size,
											   layer.isOpaque, UIScreen.main.scale)
		defer { UIGraphicsEndImageContext() }
		// Don't proceed unless we have context
		guard let context = UIGraphicsGetCurrentContext() else {
			return nil
		}
		layer.render(in: context)
		return UIGraphicsGetImageFromCurrentImageContext()
	}
}

/// used for specifying the size of objects in the scene
fileprivate struct ObjectDimensions {
	let height:CGFloat
	let width:CGFloat
	let length:CGFloat
}

/// The 3D SceneKit scene that renders the message
public final class Message3DScene: SCNScene {
	
	public enum PaperState {
		case unencrypted
		case encrypted
	}
	
	/// the message that will appear on the 3D message
	public let message: String
	
	public var paperState = PaperState.unencrypted
	
	private var paper: SCNNode!
	
	private var paperGeometry: SCNBox!
	
	private let paperSize = ObjectDimensions(height: 8, width: 5, length: 0.4)
	private let cubeSize = ObjectDimensions(height: 6, width: 6, length: 6)
	
	/// the time of the last morph, so that we don't prematurley pulse the message
	private var lastMorph = Date(timeIntervalSince1970: 0)
	
	private let whiteMaterial: SCNMaterial = {
		let material = SCNMaterial()
		material.diffuse.contents = UIColor.white
		material.locksAmbientWithDiffuse = true
		return material
	}()
	
	private lazy var messageMaterial: SCNMaterial = {
		let layer = CALayer()
		layer.frame = CGRect(x: 0, y: 0, width: 200, height: 300)
		layer.backgroundColor = UIColor.white.cgColor
		layer.contentsGravity = kCAGravityCenter
		
		var textLayer = CATextLayer()
		textLayer.frame = layer.bounds.insetBy(dx: 15, dy: 15)
		textLayer.font = CTFontCreateWithName("Courier" as CFString, 6, nil)
		textLayer.string = self.message
		textLayer.isWrapped = true
		textLayer.fontSize = 23
		textLayer.contentsGravity = kCAGravityCenter
		textLayer.alignmentMode = kCAAlignmentLeft
		textLayer.foregroundColor = UIColor.black.cgColor
		textLayer.display()
		layer.addSublayer(textLayer)
		
		let textMaterial = SCNMaterial()
		// render the layer to an UIImage to prevent display issue
		textMaterial.diffuse.contents = UIImage.image(from: layer)
		textMaterial.locksAmbientWithDiffuse = true
		return textMaterial
	}()
	
	private lazy var encryptedMaterial: SCNMaterial = {
		let layer = CALayer()
		layer.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
		layer.backgroundColor = UIColor.black.cgColor
		
		let textLayer = CATextLayer()
		textLayer.frame = layer.bounds.insetBy(dx: 10, dy: 10)
		textLayer.string = "kuhit67683o aiyefgo6217tyg8£^&Rkjdnf &cisudfyg8&^ uvisudgf87t*F&%Rgiusgdfg8i g8r7r3sr2q3trdz iuishug08y9 7g&^R&^Giusid bfiyg87tgiwubfo776r 737tf^$Euhir  g97hiu87IGI &T8ugoeihrgo8h iy89ywieufiuiYGYTFI Uiusd97fiw uebiufg87ts87f wouefiuwfuyc a98y8w7egf ihoih891729347tewgdf9guiw"
		textLayer.isWrapped = true
		textLayer.truncationMode = kCATruncationNone
		textLayer.contentsGravity = kCAGravityCenter
		textLayer.alignmentMode = kCAAlignmentLeft
		textLayer.font = CTFontCreateWithName("Courier" as CFString, 35, nil)
		textLayer.foregroundColor = UIColor.white.cgColor
		textLayer.fontSize = 23
		textLayer.display()
		layer.addSublayer(textLayer)
		
		let textMaterial = SCNMaterial()
		// render layer to UIImage to prevent simulator display issue
		textMaterial.diffuse.contents = UIImage.image(from: layer)
		textMaterial.locksAmbientWithDiffuse = true
		return textMaterial
	}()
	
	public init(message:String) {
		// initialise scene
		self.message = message
		super.init()
		// create the geometry and paper object
		paperGeometry = SCNBox(width: paperSize.width, height: paperSize.height, length: paperSize.length, chamferRadius: 0.1)
		paperGeometry.materials = [messageMaterial, whiteMaterial, messageMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
		paper = SCNNode(geometry: paperGeometry)
		self.rootNode.addChildNode(paper)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	public func morphToCrypto(duration:TimeInterval) {
		lastMorph = Date()
		// update the surface materials
		self.paperGeometry.materials = [encryptedMaterial, encryptedMaterial, encryptedMaterial, encryptedMaterial, encryptedMaterial, encryptedMaterial]
		// animate to new size
		SCNTransaction.begin()
		SCNTransaction.animationDuration = duration
		paperGeometry.height = cubeSize.height
		paperGeometry.length = cubeSize.length
		paperGeometry.width = cubeSize.width
		SCNTransaction.commit()
	}
	
	public func morphToPaper(duration:TimeInterval) {
		lastMorph = Date()
		// update the surface materials
		self.paperGeometry.materials = [messageMaterial, whiteMaterial, messageMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
		// animate to new size
		SCNTransaction.begin()
		SCNTransaction.animationDuration = duration
		paperGeometry.height = paperSize.height
		paperGeometry.width = paperSize.width
		paperGeometry.length = paperSize.length
		SCNTransaction.commit()
	}
	
	public func pulsePaper() {
		// only pulse if enough time has passed
		if Date().timeIntervalSince(lastMorph) < 0.8 {
			return
		}
		lastMorph = Date()
		let grow = SCNAction.scale(to: 1.2, duration: 0.1)
		let shrink = SCNAction.scale(to: 1, duration: 0.1)
		let pulse = SCNAction.sequence([grow,shrink])
		paper.runAction(pulse)
	}
	
	public func rotatePaper(dx: CGFloat, dy: CGFloat) {
		let rotate = SCNAction.rotateBy(x: dx, y: dy, z: 0, duration: 0.03)
		paper.runAction(rotate)
	}
	
	
}
