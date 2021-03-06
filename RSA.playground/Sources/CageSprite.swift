//
//  CageSprite.swift
//  wwdc-2018
//
//  Created by Bradley Mackey on 28/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

public final class CageSprite: SKSpriteNode {
	
	private static let textureImage = SKTexture(imageNamed: "cage.png")
	
	private let spriteSize:CGSize
	
	required public init(size:CGSize) {
		self.spriteSize = size
		super.init(texture: CageSprite.textureImage, color: .black, size: size)
		self.physicsBody = self.physicsBody(texture: CageSprite.textureImage)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: Methods
	
	private func physicsBody(texture:SKTexture) -> SKPhysicsBody {
		let body = SKPhysicsBody(texture: texture, size: self.spriteSize)
		body.categoryBitMask = PhysicsCategory.chainLink
		body.affectedByGravity = true
		body.collisionBitMask = PhysicsCategory.all ^ (PhysicsCategory.box | PhysicsCategory.privateKeys) // collide with all but box and private keys
		body.contactTestBitMask = PhysicsCategory.none
		body.allowsRotation = true
		body.restitution = 0.15
        body.mass = 0.2
		return body
	}
	
	
}
