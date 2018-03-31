//
//  RSAEncryptor.swift
//  rsa-tester
//
//  Created by Bradley Mackey on 21/03/2018.
//  Copyright © 2018 Bradley Mackey. All rights reserved.
//

import Foundation

/// manages the encryption and decryption operations for some given prime numbers and messages
public final class RSAEncryptor {
    
    // MARK: Properties
    
    // the prime numbers that we choose
	public let p:Int
    public let q:Int
	public let message:Int
	
	// just some primes so we can change incorrect user values
	private let primes = [3,5,7,11,13,17,19,23,29]
	
	/// public modulus
    public var N:Int {
        return p*q
    }

	/// public exponent
    public lazy var e:Int = {
		var candidates = Set<Int>()
		let toBeCoprime = (p-1)*(q-1) // find numbers coprime to (p-1)(q-1)
		for num in 2...13 { // limited number range so its not too big
			if RSAEncryptor.gcd(first: num, second: toBeCoprime) == 1 {
				candidates.insert(num)
			}
		}
		let numbersCount = UInt32(candidates.count)
		let random = Int(arc4random_uniform(numbersCount))
		let index = candidates.index(candidates.startIndex, offsetBy: random)
		return candidates[index]
    }()
	
	/// private exponent
    public lazy var d:Int = {
        var possibleD = 1
        // find a `d` such that e*d == 1 mod (p-1)(q-1)
        while (possibleD*e)%((p-1)*(q-1)) != 1 {
            possibleD += 1
			if possibleD > N {
				// so we dont just loop forever
				print("WE COULD NOT FIND A PRIVATE EXPONENT VALUE")
				return 0
			}
        }
        return possibleD
    }()
	
	public lazy var cipherText:Int = {
		let number = Int(pow(Double(message), Double(e)))
		let result = number % N
		return result
	}()
    
    // MARK: Lifecycle
    
	required public init(p:Int, q:Int, message:Int) {
		var tempP = p > 29 ? 29 : p
		self.q = q > 29 ? 29 : q
		self.message = message > 21 ? 21 : message
        while tempP == q {
			let random = arc4random_uniform(UInt32(self.primes.count))
			tempP = primes[Int(random)]
        }
		self.p = tempP
    }
    
    // MARK: Methods
	
    /// simple iterative gcd
    private class func gcd(first:Int, second:Int) -> Int {
        var a = first, b = second, r = 0
        while b != 0 {
            r = a % b
            a = b
            b = r
        }
        return a
    }
	
}
