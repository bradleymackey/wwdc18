// by Bradley Mackey
// for WWDC 2018

import UIKit
import SpriteKit
import PlaygroundSupport

/*:
# RSA Encryption
[RSA](https://en.wikipedia.org/wiki/RSA_(cryptosystem)) is a method of encryption that is used widely for sending secure data online.

But what makes RSA so good for use online and how does it work?

Let's start by going over the basics.
### Keys
A "key" is used *encrypt* ("lock") and *decrypt* ("unlock") data.
### Asymmetric Keys
RSA uses *asymmetric* keys to encrypt data. This means that the key used to encrypt the data is ***different*** from the key that is used to decrypt the data.

### Play time...

Go ahead and **encrypt the message** using green the *public key*.

Then **decrypt the message** using the red *private key*.

*Notice that you can only encrypt with the public key and only decrypt with the private key.*
*/

// change color of keys here

/*:
## How does it work?
### Preface: The modulo operator
RSA makes use of the *modulo* (`mod`) operator in its calculations. Don't be scared of this! It just means "the remainder after dividing". For example, `5mod2 = 1` because `5/2 = 2` ***remainder 1***.

In Swift (and many other programming languages) the modulo operator is represented by '`%`', so `5%2 = 1`.

### Preparing to encrypt
Simply put, RSA works by performing a number of maths operations on a message.

This means that to encrypt a message, it firstly has to be converted into a number (it doesn't matter what technique we use, as long as it's the same when we encrypt and decrypt). We will call the message that we will encrypt `M`.

At the heart of RSA is a number called the *public modulus*, `N`.

### Have a look!
Go ahead and **turn on** `viewMaths` to see the calculations that are done as we encrypt and decrypt!

See how the numbers `p`, `q`, `e`, `d` and `N` are used in the encryption and decryption calculations.

**Tap on the labels** for a description of what they are and what they do.
*/

// view maths toggle


/*:

### Example time!
Don't worry if things are still a little confusing, it can take some time to really understand the maths operations involved.

**Turn on** `useRealValues` to see it in action with some real numbers.

**Customise** the example by changing the message value and choosing some prime numbers for `p` and `q` (the numbers must be different from each other).

**Important:** the message must be ***less than*** the public modulus `N` (remember that `N=p*q`).

*For our example, make sure `p` and `q` are numbers 29 or less, otherwise all the numbers will be way too big! In the real world, massive numbers are used for `p` and `q` to make their encryption really secure.*

*Prime numbers to try: 3, 5, 7, 11, 13, 17, 19, 23, 29*
*/

// toggle to turn on real values
// change the RSAEncryptor engine values
// change the message value

/*:
## Sweet!
Now we understand the basics, let's go and see how it's used.

[Click Here.](@next)
*/


//let view = SKView(frame: CGRect(x: 0, y: 0, width: 500, height: 500))

// Load the SKScene from 'GameScene.sks'
//let scene = IntroScene(size: view.bounds.size)

// Set the scale mode to scale to fit the window
//scene.scaleMode = .aspectFill

// Present the scene
//view.presentScene(scene)

//PlaygroundPage.current.liveView = view


