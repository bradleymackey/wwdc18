//
//  CageSprite.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 28/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

public final class CageSprite: SKSpriteNode {
	
	private static let textureImage = CageSprite.textureForCage()
	
	private let spriteSize:CGSize
	
	public init(size:CGSize) {
		self.spriteSize = size
		super.init(texture: CageSprite.textureImage, color: .black, size: size)
		self.physicsBody = self.physicsBody(texture: CageSprite.textureImage)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Methods
	
	public class func textureForCage() -> SKTexture {
		guard let path = Bundle.main.path(forResource: "cage", ofType: "png") else {
			fatalError("ERROR: could not find cage texture")
		}
		guard let data = FileManager.default.contents(atPath: path) else {
			fatalError("ERROR: could not load cage texture")
		}
		guard let image = UIImage(data: data) else {
			fatalError("ERROR: could not interpret cage texture image")
		}
		let texture = SKTexture(image: image)
		return texture
	}
	
	private func physicsBody(texture:SKTexture) -> SKPhysicsBody {
		//let smaller = CGSize(width: self.spriteSize.width/2, height: self.spriteSize.height/2)
		let body = SKPhysicsBody(texture: texture, size: self.spriteSize)
		body.categoryBitMask = PhysicsCategory.chainLink
		body.affectedByGravity = true
		body.collisionBitMask = PhysicsCategory.all ^ (PhysicsCategory.box) // collide with all but box
		body.contactTestBitMask = PhysicsCategory.none
		body.allowsRotation = true
		body.restitution = 0.15
		return body
	}
	
	
}
