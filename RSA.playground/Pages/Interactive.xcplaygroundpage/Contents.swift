//: [Back to Introduction](@previous)

/*:
## Wait, but what's the point of having 2 different keys?
Good question.

If Alice wants to send a message to Bob and the key to encrypt and decrypt the message was the same, the only way for Alice to tell Bob what key she is going to use is to meet in person and secretly tell him (otherwise somebody else could steal the key if she sends it online)!

This is impractical on the internet. When the key used to lock the data (the public key) is different from the key used to unlock the data (the private key) it means that Bob can tell everyone what his public key is, and it doesn't mean that they can decrypt any data, because this key is only used for encrypting.
 
This means **both** Alice and Bob choose their own secret prime numbers and have their own public and private keys.

### Let's see...

Go ahead and **turn on** `snoopingEnabled` to say hello to Eve.

**Send a message** from Alice to Bob (by dragging the message and keys) and see that Eve can't read it.

*Because everyone can see the public keys, even Eve can send her own messages to Alice and Bob!*
*/

// variable to enable snooping

/*:
## How's it secure?
The security of RSA depends on the fact that the public modulus `N` is easy to calculate by multiplying `p` and `q`, but it is ***infeasible*** (really difficult) to reverse `N` to get `p` and `q`.

This is because if you were able to figure out `p` and `q`, you could easily figure out `d` and could read secure messages sent by other people!

However, we are not totally sure if this is infeasible. Read about the [P vs. NP problem](https://en.wikipedia.org/wiki/P_versus_NP_problem) if you want to learn more.

### Enough maths for one day...
Go ahead and customise the scene by changing the variables below and **have a play**!
*/

// variable to change alice's message
// variable to change bob's message
// variable to change eve's message

// change alice pub key color
// change bob pub key color

// change alice emojis
// change bob emojis
// change eve emojis

import Foundation
import UIKit
import PlaygroundSupport

var str = "Hello, playground"


let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
view.backgroundColor = .red

PlaygroundPage.current.liveView = view

