// by Bradley Mackey
// for WWDC 2018
// Page 2

import Foundation
import UIKit
import PlaygroundSupport

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

// let's see eve snoop!
InteractiveScene.snoopingEnabled = false
/*:
## How's it secure?
The security of RSA depends on the fact that the public modulus `N` is easy to calculate by multiplying `p` and `q`, but it is ***infeasible*** (really difficult) to reverse `N` to get `p` and `q`.

This is because if you were able to figure out `p` and `q`, you could easily figure out `d` and could read secure messages sent by other people!

However, we are not totally sure if this is infeasible. Read about the [P vs. NP problem](https://en.wikipedia.org/wiki/P_versus_NP_problem) if you want to learn more.

### Enough maths for one day...
Go ahead and customise the scene by changing the variables below and **have a play**!
*/

// change the messages!
InteractiveScene.aliceMessage = "Hi Bob! How are you doing? Nice weather we're having."
InteractiveScene.bobMessage = "Hi Alice! I'm great. It's cool that our we can chat in private!"
InteractiveScene.eveMessage = "Don't mind me, I'm just trying to EVEsdrop. Haha. Get it guys?"

// change the color of the keys
InteractiveScene.alicePublicColor = #colorLiteral(red: 0.02509527327, green: 0.781170527, blue: 2.601820516e-16, alpha: 1)
InteractiveScene.alicePrivateColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
InteractiveScene.bobPublicColor = #colorLiteral(red: 0.02509527327, green: 0.781170527, blue: 2.601820516e-16, alpha: 1)
InteractiveScene.bobPrivateColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)

// change the character emojis!
InteractiveScene.aliceCharacterDetails = CharacterSprite(characterName: "Alice", waiting: "💁🏽‍♀️", inRange: "👩🏽‍💻", success: "🙆🏽‍♀️", fail: "🤦🏽‍♀️")
InteractiveScene.bobCharacterDetails = CharacterSprite(characterName: "Bob", waiting: "💁🏼‍♂️", inRange: "👨🏼‍💻", success: "🙆🏼‍♂️", fail: "🤦🏼‍♂️")
InteractiveScene.eveCharacterDetails = CharacterSprite(characterName: "Eve", waiting: "💁🏻‍♀️", inRange: "👩🏻‍💻", success: "🙆🏻‍♀️", fail: "🤦🏻‍♀️")

/*:
### Thanks for playing!
Playground by Bradley Mackey.
*/

// -- present the scene --
let frame = CGRect(x: 0, y: 0, width: 500, height: 650)
let view = InteractiveView(frame: frame)
PlaygroundPage.current.liveView = view
