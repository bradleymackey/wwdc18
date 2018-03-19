// by Bradley Mackey
// for WWDC 2018

/*:
# RSA Encryption
[RSA](https://en.wikipedia.org/wiki/RSA_(cryptosystem)) is the technique used to encrypt most of the data that we send and recieve online.

But what makes RSA so good for use online and how does it work?

Let's start by going over the basics.
### Keys
A "key" is used *encrypt* ("lock") and *decrypt* ("unlock") data.
### Asymmetric Keys
RSA uses *asymmetric* keys to encrypt data. Asymmetric is the opposite of symmetry.

This means that the key used to encrypt the data is **different** from the key that is used to decrypt the data. In RSA, these keys are known as the *public key* and *private key*.

### Play time...

Go ahead and **encrypt the message** using green the *public key*.

Then use the red *private key* to **decrypt the message**.

Notice that you can only encrypt with the public key and only decrypt with the private key.
*/

// change color of keys here

/*:
## How does it work?
blah blah modulo blah blah public and private key

Go ahead and turn on `viewMaths` to see the calculations that are done as we encrypt and decrypt!
*/

// boolean to toggle the maths view to see the modulo calculation
// user can change the message here to be anything they want

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

/*:
## Sweet!
Now we understand the basics, let's go and see how it's used.

[Click Here.](@next)
*/


