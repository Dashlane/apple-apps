public typealias CompletionBlock<T, E: Error> = (Result<T, E>) -> Void
public typealias Completion<T> = (Result<T, Error>) -> Void
public typealias VoidCompletionBlock = () -> Void
