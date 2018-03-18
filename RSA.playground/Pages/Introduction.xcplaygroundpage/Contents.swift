
//: # RSA Encryption

import UIKit
import SpriteKit
import PlaygroundSupport


let view = SKView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

// Load the SKScene from 'GameScene.sks'
let scene = IntroScene(size: view.bounds.size)

// Set the scale mode to scale to fit the window
scene.scaleMode = .aspectFill

// Present the scene
view.presentScene(scene)

PlaygroundPage.current.liveView = view

//: [Click Here to try it out!](@next)
