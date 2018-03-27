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
RSA uses *asymmetric* keys to encrypt data. This means that the key used to encrypt the data is **different** from the key that is used to decrypt the data.

### Play time...

Go ahead and **encrypt the message** using green the *public key*.

Then **decrypt the message** using the red *private key*.

Notice that you can only encrypt with the public key and only decrypt with the private key.
*/

// change color of keys here

/*:
## How does it work?
### Preface: The modulo operator
RSA makes use of the *modulo* (`mod`) operator in its calculations. Don't be scared of this! It just means "the remainder after dividing". For example, `5mod2 = 1` because `5/2 = 2` ***remainder 1***.

In Swift (and many other programming languages) the modulo operator is represented by '`%`', so `5%2 = 1`.

### Preparing to encrypt
Simply put, RSA works by performing a number of maths operations on a message.

This means that to encrypt a message, it firstly has to be converted into a number (it doesn't matter what technique we use to do this, as long as it's the same when we encrypt and decrypt). We will call the message that we will encrypt '`M`'.

At the heart of the encryption is a number called the *public modulus*, '`N`' (we'll explain how we got this in a minute).

### Have a look!
Go ahead and turn on `viewMaths` to see the calculations that are done as we encrypt and decrypt!

See how the numbers `e`, `d` and `N` associated with the keys is used in the encryption and decryption calculations.

**Tap on the labels** for a description of what they are and what they do.
*/

// view maths toggle

// these should be inside the labels that we tap on.
//### `p` and `q`
//These are just 2 numbers that we pick. They can be anything we want with 2 simple rules:
//- they must be *prime numbers*
//- they must be different
//
//### Public Modulus, `N`
//Calculating `N` is really easy. We just multiply `p` and `q`.
//
//### Public Exponent, `e`
//`e` is also easy to figure out. It can be any number that we want that is *co-prime* to `(p-1)*(q-1)`. This means the only factor that they have in common is 1.
//
//An easy way to get `e` is to just use another prime number, because prime numbers share no factors apart from 1 with any other number.
//
//### Private Exponent, `d`
//`d` is a little trickier. It is the **unique** integer such that `e*d = 1 mod (p-1)*(q-1)` (there's only 1 possible value that `d` can be to make this equation work).

/*:

### Example time!
Don't worry if things are still a little confusing, it can take some time to really understand the maths operations involved.

Turn on `useRealValues` to see it in action with some real numbers.
*/

// toggle to turn on real values

/*:

### Customise it!
Go ahead and customise the example by changing the message value and choosing some different prime numbers for `p` and `q`.

*For our example, make sure `p`, `q` and the message are numbers 23 or less, otherwise all the numbers will be way too big! In the real world, massive numbers are used for `p` and `q` to make their encryption really secure.*
*/


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


