//: [Back to Introduction](@previous)

/*:
## Wait, but whats the point of 2 keys?
Good point.

its so we lock up some data to send without having to send a key thats the same blah blah...

Go ahead and turn on `snoopingEnabled` to see that RSA is secure and say hello to Eve.
*/
// variable to enable snooping
/*:
## How do we know it's secure?
We don't. Well... sort of.

touch on P = NP, touch on modulo easy one way but hard to reverse

### Phew, enough maths for one day...
Go ahead and customise the scene by changing the variables below and have a play!
*/

// viewMaths toggle
// variable to change alice's message
// variable to change bob's message
// change alice pub key color
// change bob pub key color
// change alice emoji
// change bob emoji
// change eve emoji



import Foundation
import UIKit
import PlaygroundSupport

var str = "Hello, playground"


let view = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
view.backgroundColor = .red

PlaygroundPage.current.liveView = view

