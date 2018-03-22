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
### The modulo operator
RSA makes heavy use of the *modulo* (`mod`) operator in its calculations. Don't be scared of this! It just means "the remainder after dividing". For example, `5mod2 = 1` because `5/2 = 2` ***remainder 1***.

In Swift (and many other programming languages) the modulo operator is represented by '`%`', so `5%2 = 1`.

### The algorithm
To encrypt a message, the text is first converted into a number (it doesn't matter what technique we use to do this, as long as it's the same when we encrypt and decrypt). This is so we can do some fancy maths operations with the number in order to make it secure.

If the message is big, the number will also be big.

We now need to generate the keys so we know how to encrypt and decrypt the message.

1. We pick 2 prime numbers, `p` and `q`. The bigger that the numbers are, the more secure our message will be.
2. We then calculate `N = p*q`. This number is called the *public modulus* and is used both when we encrypt and decrypt the message.
3. Then we pick some number `e`, which must be *co-prime* to `(p-1)*(q-1)` (the only factor that they share is 1). This number is called the *public exponent*.
4. Then we calculate `d`, which is the **unique** integer such that `e*d = 1 mod (p-1)*(q-1)` (there's only 1 possible value that `d` can be to make this equation work).
5. The public key is made up of both `N` and `e`.
6. The private key is made up of both `N` and `d`.

To encrypt some message `M`, we calculate `C = M^e mod N`, where `C` is the encrypted message or *cipertext*.

To decrypt the cipertext, we calculate `M = C^d mod N`, where `M` is the original message.

### Try it out!

Let's see it in action.

Go ahead and turn on `viewMaths` to see the calculations that are done as we encrypt and decrypt!

To keep things simple, the `p`, `q` and the message are very small numbers, longer messages would require much longer numbers in the real world.
*/

// boolean to toggle the maths view to see the modulo calculation

/*:
### A real example?
Turn on `useRealValues` to see it in action with some real numbers.
*/

// toggle to turn on real values

/*:
## Customise it!
Change some of the numbers to see how the message gets encrypted differently!

*For our example, make sure `p`, `q` and the message are numbers less than 18, otherwise the numbers will be way too big!*

*Note that because the numbers we are using are really small, some numbers you pick may mean that the public and private keys have the same value - this wouldn't happen in the real world because the numbers are much bigger! It may also be the case that the message after it's encrypted is the same as the original message. Again, this wouldn't happen in the real world with the massive numbers!*
*/

// change the RSAEncryptor engine values
// change the message value

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
