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
	
	/// public modulus
    public var N:Int {
        return p*q
    }
	
	/// public exponent
    public lazy var e:Int = {
        let primes = [3,5,7,11,13,17,19,23]
        let primeCount = UInt32(primes.count)
		let index = Int(arc4random_uniform(primeCount))
        return primes[index]
    }()
	
	/// private exponent
    public lazy var d:Int = {
        var possibleD = 1
        // find a `d` such that e*d == 1 mod (p-1)(q-1)
        while (possibleD*e)%((p-1)*(q-1)) != 1 {
            possibleD += 1
        }
        return possibleD
    }()
    
    // MARK: Lifecycle
    
    required public init(p:Int, q:Int) {
        self.p = p
        self.q = q
		if p > 29 || q > 29 {
			fatalError("p and q must be 29 or less!")
		}
        if p == q {
            fatalError("p and q must be different!")
        }
    }
    
    // MARK: Methods
    
    /// encrypts a message based on the public modulus and `e`
    public func encryption(forMessage message:Int) -> Int {
        let value = Int(pow(Double(message), Double(e)))
        return value % Int(N)
    }
	
    /// decrypts some cipertext based on the public modulus and `d`
    public func decryption(forCipherText ciper:Int) -> Int {
        let value = Int(pow(Double(ciper), Double(d)))
        return value % Int(N)
    }
    
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
