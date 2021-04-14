import Foundation

/*
 Identifiable mutex lock which does thread locking of Hashable instances per their identifiers
 Allows only one identifier to be changed at the same time
 
 Per identifier locking is implented using a Dictionary of objects hasValue string as key and DispatchSemaphore as value
 When performChanges: is called with given object a semaphore.wait() is called synchronously until ongoing changes to
 identifier in question are finished
 */
public class IdentifiableLock<T:Hashable> {
    
    /// Serial queue used to synchronize access to locks dictionary
    private let serialQueue = DispatchQueue(label: "IdentifiableLock queue")
        
    /// Locks dictionary keeping references to DispatchSemaphore corresponding to Ids
    private var locks = [String:DispatchSemaphore]()
    
    /// Synchronously perform changes on given object executed in completion block
    ///  Will block the running queue
    /// - Parameters:
    ///   - object: object to change
    ///   - completion: block with the changes
    public func performChanges(object:T,
                      completion: @escaping () -> Void) {
        
        assert(!Thread.isMainThread, "performChanges: called from main thread")
            
        let identifier = String(object.hashValue)
            
        self.wait(id: identifier)
            
        completion()
        
        self.signal(id: identifier)
    }
    
    private func wait(id:String)  {
        
        var semaphore : DispatchSemaphore?
        self.serialQueue.sync {
            
            if let semaphoreLock = locks[id] {
                
                semaphore = semaphoreLock
            } else {
                
                self.locks[id] = DispatchSemaphore(value: 0)
            }
        }
        semaphore?.wait()
    }
    
    private func signal(id:String) {
        
        serialQueue.sync {
            
            guard let semaphore = locks[id] else {
                return
            }
            
            let awoken = semaphore.signal()
            
            if awoken == 0 {
                
                _ = locks.removeValue(forKey: id)
            }
        }
    }
}
