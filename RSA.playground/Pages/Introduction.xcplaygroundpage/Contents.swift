// by Bradley Mackey
// for WWDC 2018

/*:
# RSA Encryption
RSA is the modern way to encrypt data.
It is used in almost every context in the modern age of computing.
*/


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

//: [Let's see RSA in action](@next)


