//
//  MoveableSprite.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 24/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation
import SpriteKit

/// indicates that a sprite can be moved by dragging it
public protocol MoveableSprite {
    func startMoving(initialPoint:CGPoint)
    func updatePositionIfNeeded(to point: CGPoint)
    func stopMoving(at lastPoint:CGPoint)
}
