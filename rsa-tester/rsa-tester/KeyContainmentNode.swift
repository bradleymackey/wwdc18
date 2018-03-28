//
//  KeyContainmentNode.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 28/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

/// for the interactive scene
public final class KeyContainmentNode: SKNode {
    
    private let keySize:CGSize
    
    private var cageSize:CGSize {
        return CGSize(width: keySize.width+50, height: keySize.height+50)
    }
    
    private lazy var cageNode:SKSpriteNode = {
        let cage = SKSpriteNode(imageNamed: "cage.png")
        cage.size = self.cageSize
        cage.position = CGPoint(x: 0, y: 10)
        //cage.zRotation = -0.1
        cage.alpha = 1
        return cage
    }()
    
    public init(forKeySize size:CGSize) {
        self.keySize = size
        super.init()
        self.physicsBody = self.physicsBody()
        self.addChild(self.cageNode)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func physicsBody() -> SKPhysicsBody {
        let body = SKPhysicsBody(circleOfRadius: cageSize.width)
        body.affectedByGravity = true
        body.allowsRotation = true
        return body
    }
    
}
