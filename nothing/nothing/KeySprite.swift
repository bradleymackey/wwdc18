//
//  KeySprite.swift
//  nothing
//
//  Created by Bradley Mackey on 19/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

public final class KeySprite: SKSpriteNode {
	
	public enum Owner {
		case alice
		case bob
	}
	
	public enum KeyType {
		case pub
		case priv
	}
	
	/// the size of the key
	static let size:CGFloat = 50
	
	/// whether the user is dragging this key around or not
	public var isBeingMoved = false
	/// the previous point that the key was at
	public var lastPoint:CGPoint?
	
	/// who owns the key
	public let owner: Owner
	/// what type of key is this?
	public let type: KeyType
	
	var publicKeyAlice:Bool {
		return owner == .alice && type == .pub
	}
	
	var publicKeyBob:Bool {
		return owner == .bob && type == .pub
	}
	
	var privateKeyAlice:Bool {
		return owner == .alice && type == .priv
	}
	
	var privateKeyBob:Bool {
		return owner == .bob && type == .priv
	}
	
	var categoryMask:UInt32 {
		if publicKeyAlice {
			return PhysicsCategory.publicKeyA
		} else if publicKeyBob {
			return PhysicsCategory.publicKeyB
		} else if privateKeyAlice {
			return PhysicsCategory.privateKeyA
		} else {
			return PhysicsCategory.privateKeyB
		}
	}
	
	public init(texture: SKTexture, color: UIColor, owner: Owner, type: KeyType) {
		self.owner = owner
		self.type = type
		let size = CGSize(width: KeySprite.size, height: KeySprite.size)
		super.init(texture: texture, color: color, size: size)
		self.setup(texture: texture, size: size)
	}
	
	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setup(texture:SKTexture,size:CGSize) {
		self.colorBlendFactor = 1
		self.physicsBody = SKPhysicsBody(texture: texture, size: size)
		self.physicsBody?.categoryBitMask = categoryMask // determine the correct category
		self.physicsBody?.affectedByGravity = true
		self.physicsBody?.collisionBitMask = PhysicsCategory.all ^ PhysicsCategory.box // collide with all but box
		self.physicsBody?.contactTestBitMask = PhysicsCategory.box
		self.physicsBody?.allowsRotation = true
		self.physicsBody?.restitution = 0.1
		self.physicsBody?.mass = 0.5
	}
	
	public func startMoving(initialPoint:CGPoint) {
		self.isBeingMoved = true
		self.removeAllActions()
		let moveAnimation = SKAction.move(to: initialPoint, duration: 0.04)
		self.run(moveAnimation)
		self.physicsBody?.affectedByGravity = false
		self.lastPoint = initialPoint
	}
	
	public func updatePositionIfNeeded(to point: CGPoint) {
		guard isBeingMoved else { return }
		let moveAnimation = SKAction.move(to: point, duration: 0.02)
		self.run(moveAnimation)
		self.lastPoint = point
	}
	
	public func stopMoving(at lastPoint:CGPoint) {
		defer { self.isBeingMoved = false }
		guard isBeingMoved else { return }
		self.removeAllActions()
		self.physicsBody?.affectedByGravity = true
		guard let previousPoint = self.lastPoint else { return }
		let moveX = lastPoint.x - previousPoint.x
		var moveY = lastPoint.y - previousPoint.y
		// extra y velocity to fight gravity
		if moveY > 0 { moveY *= 2 }
		let vec = CGVector(dx: moveX*25, dy: moveY*25)
		let fling = SKAction.applyImpulse(vec, duration: 0.005)
		self.run(fling)
		
	}
	
}
