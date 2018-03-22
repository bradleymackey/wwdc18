//
//  RSAScene.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 22/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

/// a scene that implements shared functionality between the intro scene and interactive scene
public class RSAScene: SKScene {
	
	/// simply loads the key texture so we don't have to reload it for each key
	public static let keyTexture = KeySprite.textureForKey()
	
	/// the basic structure of a maths labels, which all labels share
	public class func mathsLabel(text:String,fontSize:CGFloat,color:UIColor,bold:Bool) -> SKLabelNode {
		let label = SKLabelNode(fontNamed: bold ? "Courier-Bold" : "Courier")
		label.text = text
		label.fontSize = fontSize
		label.fontColor = color
		label.verticalAlignmentMode = .center
		label.horizontalAlignmentMode = .center
		return label
	}
	
	public class func worldPhysicsBody(frame:CGRect) -> SKPhysicsBody {
		let body = SKPhysicsBody(edgeLoopFrom: frame)
		body.affectedByGravity = false
		body.categoryBitMask = PhysicsCategory.boundry
		body.contactTestBitMask = PhysicsCategory.none
		body.collisionBitMask = PhysicsCategory.all
		return body
	}
	
	/// moves a node above another node
	public func move(node:SKNode, above mainNode:SKNode, by amount:CGFloat) {
		let point = CGPoint(x: mainNode.position.x, y: mainNode.position.y+amount)
		let moveToPosition = SKAction.move(to: point, duration: 0.01)
		node.run(moveToPosition)
	}

}
