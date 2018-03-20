// by Bradley Mackey
// for WWDC 2018

/*:
# RSA Encryption
[RSA](https://en.wikipedia.org/wiki/RSA_(cryptosystem)) is the main technique used to encrypt data sent and recieved online.

But what makes RSA so good for use online and how does it work?

Let's start by going over the basics.
### Keys
A "key" is used *encrypt* ("lock") and *decrypt* ("unlock") data.
### Asymmetric Keys
RSA uses *asymmetric* keys to encrypt data.

This means that the key used to encrypt the data is **different** from the key that is used to decrypt the data. In RSA, these keys are known as the *public key* and *private key*.

### Play time...

Go ahead and **encrypt the message** using green the *public key*.

Then use the red *private key* to **decrypt the message**.

Notice that you can only encrypt with the public key and only decrypt with the private key.
*/

// change color of keys here

/*:
## How does it work?
To encrypt a message, the text is first converted into a big number (it doesn't matter what technique we use to do this, as long as it's the same when we encrypt and decrypt). This is so we can do some fancy maths operations with the number in order to make it secure.

We now need to generate the keys so we know how to encrypt and decrypt the message.

1. We pick 2 prime numbers, `p` and `q`. The bigger that the numbers are, the more secure our message will be.
2. We then calculate `N=p*q`. This number is called the *public modulus* and is used both when we encrypt and decrypt the message.
3. Then we calculate `e`, which must be *co-prime* to `(p-1)(q-1)`. This number is called the *public exponent*.
4. The public key is the tuple `(N,e)`. This is all the information we need to encrypt a message.
5. Then we calculate `d`, which is the **unique** integer such that `e*d=1mod(p-1)(q-1)`.
6. The private key is the tuple `(N,d)`.

To encrypt some message `M`, we calculate `C = M^e mod N`, where `C` is the encrypted message or *cipertext*.

To decrypt the cipertext, we calculate `M = C^d mod N`, where `M` is the original message.

### Have a look...

Go ahead and turn on `viewMaths` to see the calculations that are done as we encrypt and decrypt!
*/

// boolean to toggle the maths view to see the modulo calculation
// user can change the message here to be anything they want

import UIKit
import SpriteKit
import PlaygroundSupport


//let view = SKView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

// Load the SKScene from 'GameScene.sks'
//let scene = IntroScene(size: view.bounds.size)

// Set the scale mode to scale to fit the window
//scene.scaleMode = .aspectFill

// Present the scene
//view.presentScene(scene)

//PlaygroundPage.current.liveView = view

/*:
## Sweet!
Now we understand the basics, let's go and see how it's used.

[Click Here.](@next)
*/
