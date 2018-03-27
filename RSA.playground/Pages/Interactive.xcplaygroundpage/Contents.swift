//: [Back to Introduction](@previous)

/*:
## Wait, but what's the point of having 2 different keys?
Good question.

If Alice wants to send a message to Bob and the key to encrypt and decrypt the message was the same, the only way for Alice to tell Bob what key she is going to use is to meet in person (otherwise somebody else could steal the key as well)!

This is impractical on the internet. When the key used to lock the data (the public key) is different from the key used to unlock the data (the private key) it means that Bob can tell everyone what his public key is, and it doesn't mean that they can decrypt any data sent to him.

Go ahead and turn on `snoopingEnabled` to see that RSA is secure and say hello to Eve.
*/

// variable to enable snooping

/*:
## How's it secure?
The security of RSA depends on the fact that the public modulus `N` is easy to calculate by multiplying `p` and `q`, but it is ***infeasible*** to reverse `N` to get `p` and `q`.

This is because if you were able to figure out `p` and `q`, you could easily figure out `d` and could read secure messages sent by other people!

However, we are not totally sure if this is infeasible. Read about [the P=NP problem](https://en.wikipedia.org/wiki/P_versus_NP_problem) if you want to learn more.

### Phew, enough maths for one day...
Go ahead and customise the scene by changing the variables below and have a play!
*/

// viewMaths toggle
// variable to change alice's message
// variable to change bob's message
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

