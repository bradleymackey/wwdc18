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
    
    public var N:Int {
        return p*q
    }
    
    public lazy var e:Int = {
        let toBeCoprime = (p-1)*(q-1)
        var possibleE = 1
        var termination = 0
        while termination != 1 {
            possibleE += 1
            termination = RSAEncryptor.gcd(first: possibleE, second: toBeCoprime)
        }
        return possibleE
    }()
    
    public lazy var d:Int = {
        var possibleD = 1
        // find a D such that e*d == 1 mod (p-1)(q-1)
        while (possibleD*e)%((p-1)*(q-1)) != 1 {
            possibleD += 1
        }
        return possibleD
    }()
    
    // MARK: Lifecycle
    
    public init(p:Int, q:Int) {
        self.p = p
        self.q = q
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
    
    /// simple iterative gcd function
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
