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


let view = SKView(frame: CGRect(x: 0, y: 0, width: 450, height: 350))

// Load the SKScene from 'GameScene.sks'
let scene = IntroScene(size: view.bounds.size)

// Set the scale mode to scale to fit the window
scene.scaleMode = .aspectFill

/*:
### Asymmetric Keys
Go ahead and encrypt the message using the public key.

Then try to to decrypt it using *the same public key*. It doesn't work.
*/


// Present the scene
view.presentScene(scene)

PlaygroundPage.current.liveView = view

/*:
Sweet! Now we understand the basics, let's go and see how it's used.

[Click Here.](@next)
*/
