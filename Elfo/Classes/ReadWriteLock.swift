//
//  ReadWriteLock.swift
//  Elfo
//
//  Created by Douwe Bos on 12/10/21.
//

import Foundation

/// Used to synchronise reading and writing of propties within the closures
class ReadWriteLock {
    let queue: DispatchQueue
    
    
    /// Initialize a new lock
    /// - Parameter label: The label used to identify the queue.
    init(label: String) {
        self.queue = DispatchQueue(label: label, qos: .utility, attributes: .concurrent)
    }
    
    
    /// Run the closure used to read from a property in a synchronized manner.
    /// - Parameter closure: Closure that does the reading
    /// - Returns: Void
    func read(closure: () -> ()) {
        self.queue.sync {
            closure()
        }
    }
    
    
    /// Run the closure used to read from a property in a synchronized manner, and return the retrieved closure. This is useful for synchronized reading and copying of a value type.
    /// - Parameter closure: Closure that does the reading
    /// - Returns: The retrieved property.
    func readReturn<T>(closure: () -> T) -> T {
        self.queue.sync {
            return closure()
        }
    }
    
    
    /// Write to a property in a synchronized manner.
    /// - Parameter closure: Closure that does the writing
    /// - Returns: Void
    func write(closure: () -> ()) {
        self.queue.sync(flags: .barrier) {
            closure()
        }
    }
}
