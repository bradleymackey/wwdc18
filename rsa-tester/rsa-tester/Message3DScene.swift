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
	
	// MARK: Constants
	public static let surfaceFontSize:CGFloat = 17
	public static var paperColors:(text:UIColor,background:UIColor) = (text: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1), background: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
	public static var encryptedColors:(text:UIColor,background:UIColor) = (text: #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), background: #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
	
	// MARK: Properties
	
	/// the message that will appear on the 3D message
	public var message: String
	/// the current state of the paper
	public var paperState = PaperState.unencrypted
    /// the person that has encrypted the message
    public var encryptedBy:KeyOwner?
    
    /// for the interactive scene, this is the person's message we are currently showing
    public var currentlyDisplayingMessage:InteractiveScene.SceneCharacters = .alice
	
	/// the paper/encrypted box object
	private lazy var paper: SCNNode = {
		return SCNNode(geometry: paperGeometry)
	}()
	/// the geometry of the paper. this gets animated to change the dimensions of the box
	private lazy var paperGeometry: SCNBox = {
		let geometry = SCNBox(width: paperSize.width, height: paperSize.height, length: paperSize.length, chamferRadius: 0.05)
		geometry.materials = [messageMaterial, whiteMaterial, messageMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
		return geometry
	}()
	/// the dimensions of the unencrypted paper
	private let paperSize = ObjectDimensions(height: 2, width: 1.25, length: 0.1)
	/// the dimensions of the encrypted cube
	private let cubeSize = ObjectDimensions(height: 1.5, width: 1.5, length: 1.5)
    /// the size of the question mark cube
    private let questionMarkSize = ObjectDimensions(height: 1.25, width: 1.25, length: 1.25)
    
    /// the materials that were used prior to encryption
    /// - important: this is needed because any of the characters in the interactive scene can change the message, so we need to know what is was before we encrypt it
    private var priorMaterials:[SCNMaterial]?
	
	
	/// blank white material to show on sides of the paper without text
	private let whiteMaterial: SCNMaterial = {
		let material = SCNMaterial()
		material.diffuse.contents = Message3DScene.paperColors.background
		material.locksAmbientWithDiffuse = true
		return material
	}()
	
	/// the regular text surface on the unencrypted box
	/// - note: must be lazy so that we are able to know what the message is after initilisation
	private lazy var messageMaterial: SCNMaterial = {
		return Message3DScene.messageMaterial(forText: self.message)
	}()
    
    private let aliceMaterial: SCNMaterial = {
        return Message3DScene.messageMaterial(forText: InteractiveScene.aliceMessage)
    }()
    
    private let bobMaterial: SCNMaterial = {
        return Message3DScene.messageMaterial(forText: InteractiveScene.bobMessage)
    }()
    
    private let eveMaterial: SCNMaterial = {
        return Message3DScene.messageMaterial(forText: InteractiveScene.eveMessage)
    }()
	
	/// the encrypted text on the ciper block (same material all sides)
	private let encryptedMaterial: SCNMaterial = {
		// create the surface image
		let encryptedMessage = "kuhit67683o aiyefgo6217tyg8£^&Rkjdnf &cisudfyg8&^ uvisudgf87t*F&%Rgiusgdfg8i g8r7r3sr2q3trdz iuishug08y9 7g&^R&^Giusid bfiyg87tgiwubfo776r 737tf^$Euhir  g97hiu87IGI &T8ugoeihrgo8h iy89ywieufiuiYGYTFI Uiusd97fiw uebiufg87ts87f wouefiuwfuyc a98y8w7egf ihoih891729347tewgdf9guiw"
		let encryptedSize = CGSize(width: 150, height: 150)
		let textColor = Message3DScene.encryptedColors.text
		let backgroundColor = Message3DScene.encryptedColors.background
		let surfaceImage = Message3DScene.renderedTextImage(message: encryptedMessage, size: encryptedSize, textColor: textColor, backgroundColor: backgroundColor)
		// create the material
		let textMaterial = SCNMaterial()
		textMaterial.diffuse.contents = surfaceImage
		textMaterial.locksAmbientWithDiffuse = true
		return textMaterial
	}()
	
	/// the question mark material (same on all sides of the message block)
    private let questionMarkMaterial: SCNMaterial = {
        // create the surface image
        let message = "?"
        let encryptedSize = CGSize(width: 150, height: 150)
        let textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let backgroundColor = #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
        let surfaceImage = Message3DScene.renderedTextImage(message: message, size: encryptedSize, textColor: textColor, backgroundColor: backgroundColor, superLarge: true)
        // create the material
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = surfaceImage
        textMaterial.locksAmbientWithDiffuse = true
        return textMaterial
    }()
	
	// MARK: Lifecycle
	
	public init(message:String) {
		// initialise scene
		self.message = message
		super.init()
		// add the paper to the scene
		self.rootNode.addChildNode(paper)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Methods
    
    private class func messageMaterial(forText text:String) -> SCNMaterial {
        // create the surface image
        let paperSize = CGSize(width: 150, height: 225)
        let textColor = Message3DScene.paperColors.text
        let backgroundColor = Message3DScene.paperColors.background
        let surfaceImage = Message3DScene.renderedTextImage(message: text, size: paperSize, textColor: textColor, backgroundColor: backgroundColor)
        // create the material
        let textMaterial = SCNMaterial()
        textMaterial.diffuse.contents = surfaceImage
        textMaterial.locksAmbientWithDiffuse = true
        return textMaterial
    }
	
    private class func renderedTextImage(message:String, size:CGSize, textColor:UIColor, backgroundColor:UIColor, superLarge:Bool = false) -> UIImage? {
		let layer = CALayer()
		layer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
		layer.backgroundColor = backgroundColor.cgColor
		// create the text layer and add as a sublayer
		let textLayer = CATextLayer()
		textLayer.frame = layer.bounds.insetBy(dx: 10, dy: 10)
		textLayer.string = message
		textLayer.isWrapped = true
		textLayer.truncationMode = kCATruncationNone
		textLayer.contentsGravity = kCAGravityCenter
        textLayer.alignmentMode = superLarge ? kCAAlignmentCenter : kCAAlignmentLeft
		textLayer.font = CTFontCreateWithName("Courier" as CFString, 35, nil)
		textLayer.foregroundColor = textColor.cgColor
        textLayer.fontSize = superLarge ? 100 : Message3DScene.surfaceFontSize
		textLayer.display()
		layer.addSublayer(textLayer)
		// create the image and return
		return UIImage.image(from: layer)
	}
	
	public func morphToCrypto(duration:TimeInterval) {
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
		// update the surface materials
		// if we have prior materials use that, otherwise use the default texture
        if let prior = self.priorMaterials {
             self.paperGeometry.materials = prior
        } else {
            self.paperGeometry.materials = [messageMaterial, whiteMaterial, messageMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
        }
		// animate to new size
		SCNTransaction.begin()
		SCNTransaction.animationDuration = duration
		paperGeometry.height = paperSize.height
		paperGeometry.width = paperSize.width
		paperGeometry.length = paperSize.length
		SCNTransaction.commit()
	}
    
    public func morphToQuestionMark(duration:TimeInterval) {
        // update the surface materials
        self.paperGeometry.materials = [questionMarkMaterial, questionMarkMaterial, questionMarkMaterial, questionMarkMaterial, questionMarkMaterial, questionMarkMaterial]
        // animate to new size
        SCNTransaction.begin()
        SCNTransaction.animationDuration = duration
        paperGeometry.height = questionMarkSize.height
        paperGeometry.width = questionMarkSize.width
        paperGeometry.length = questionMarkSize.length
        SCNTransaction.commit()
    }
	
	public func rotatePaper(dx: CGFloat, dy: CGFloat) {
		SCNTransaction.begin()
		SCNTransaction.animationDuration = 0.03
		paper.eulerAngles.x += Float(dx)
		paper.eulerAngles.y += Float(dy)
		SCNTransaction.commit()
	}
    
    /// - note: call from background thread for improved performance
    public func updateMessageIfUnencrypted(toPerson person:InteractiveScene.SceneCharacters) {
        guard paperState == .unencrypted else { return }
        // only change the message if it is different
        guard self.currentlyDisplayingMessage != person else { return }
        self.currentlyDisplayingMessage = person
		// determine the new paper material for this new person
		var newMaterialsToUse: [SCNMaterial]
        switch person {
        case .alice:
			newMaterialsToUse = [aliceMaterial, whiteMaterial, aliceMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
        case .bob:
			newMaterialsToUse = [bobMaterial, whiteMaterial, bobMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
        case .eve:
			newMaterialsToUse = [eveMaterial, whiteMaterial, eveMaterial, whiteMaterial, whiteMaterial, whiteMaterial]
        }
		// set the current material and the prior material, so we know what the decryption should be
		self.paperGeometry.materials = newMaterialsToUse
		self.priorMaterials = newMaterialsToUse
    }
	
}



