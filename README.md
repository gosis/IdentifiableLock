# IdentifiableLock

 Identifiable mutex lock which does thread locking of `Hashable` instances per their identifiers
 Allows only one identifier to be changed at the same time
 
* Per identifier locking is implented using a Dictionary of objects with `hasValue` string as key and `DispatchSemaphore` as value
* When `performChanges:` is called with given object a `semaphore.wait()` is called synchronously until ongoing changes to
 identifier in question are finished
