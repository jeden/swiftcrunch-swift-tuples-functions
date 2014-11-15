/**
 * Sample code for the lighning talk
 * Swift Tuples and Functions
 * SwiftCrunch @ Krakow - Nov 16, 2014
 *
 * Sample code demonstrating how to use tuples to buffer function calls 
 * and related parameters in a queue, processed sequentally
 *
 * MIT license
 */

import Foundation

// Protocol just for convenience
protocol DataStorageProtocol {
    func save(#date: NSDate, text: String, author: String)
}

/**
 * Base class implementing the protocol.
 * Note that a concrete class is needed in order to call class methods as curried functions
 * It doesn't work with a protocol
 */
class DataStorage : DataStorageProtocol {
    func save(#date: NSDate, text: String, author: String) {}
}

/** 
 * Hypotethical class storing data to a file
 * The implementation actually
 */
class JsonExporter : DataStorage {
    override func save(#date: NSDate, text: String, author: String) {
        println("{ \"date\": \"\(date)\", \"test\": \"\(text)\", \"author\": \"\(author)\"}")
    }
}





/**
 * Class printing data to the output console
 */
class ConsoleStorage : DataStorage {
    // Property used to differentiate instances when printing to the console
    var instanceNumber: Int
    
    required init(instanceNumber: Int) {
        self.instanceNumber = instanceNumber
    }
    
    override func save(#date: NSDate, text: String, author: String) {
        println("[\(self.instanceNumber)] [\(date)] [\(author)] \(text)")
    }
}





// Alias for the parameters accepted by the save() method
typealias StorageParams = (date: NSDate, text: String, author: String)

// Alias for the tuple used as the array generic type to store deferred method calls
typealias BufferStorageParams = (instance: DataStorage, params: StorageParams)





/**
 * The call serializer
 */
class StorageSerializer {
    private var buffer = [BufferStorageParams]()
    
    func enqueue(instance: DataStorage, date: NSDate, text: String, author: String) {
        let params = (date: date, text: text, author: author)
        let bufferParams = (instance: instance, params: params)
        buffer.append(bufferParams)
    }
    
    func process() {
        while buffer.isEmpty == false {
            let bufferParams = buffer.removeAtIndex(0)
            // Class methods are curried functions
            let method = DataStorage.save(bufferParams.instance)
            let params = bufferParams.params
            method(params)
        }
    }
}

let consoleStorage1 = ConsoleStorage(instanceNumber: 1)
let consoleStorage2 = ConsoleStorage(instanceNumber: 2)
let jsonExporter = JsonExporter()

let storageSerializer = StorageSerializer()

storageSerializer.enqueue(consoleStorage1, date: NSDate(), text: "Test Message", author: "SwiftCrunch")
storageSerializer.enqueue(consoleStorage2, date: NSDate(), text: "Another Message", author: "Antonio Bello")
storageSerializer.enqueue(consoleStorage1, date: NSDate(), text: "Hope it's useful", author: "Swift Tuples")
storageSerializer.enqueue(jsonExporter, date: NSDate(), text: "Json exporter", author: "Me")

storageSerializer.process()
