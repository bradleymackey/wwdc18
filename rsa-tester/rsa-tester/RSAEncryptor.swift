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
        var possibleE = 0
        while possibleE != 1 {
            possibleE += 1
            possibleE = RSAEncryptor.gcd(first: possibleE, second: toBeCoprime)
        }
        return possibleE
    }()
    
    public lazy var d:Int = {
        let toBeCoprime = (p-1)*(q-1)
        
        return 0
    }()
    
    // MARK: Lifecycle
    
    public init(p:Int, q:Int) {
        self.p = p
        self.q = q
    }
    
    // MARK: Methods
    
    public func encryption(forMessage message:Int) -> Int {
        let value = Int(powf(Float(message), Float(e)))
        return value % Int(N)
    }
    
    public func decryption(forCipherText ciper:Int) -> Int {
        let value = Int(powf(Float(ciper), Float(d)))
        return value % Int(N)
    }
    
    /// simple gcd function
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
