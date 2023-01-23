import Combine

public extension Publisher {

                                func debounceExceptFirst<S: Scheduler>(
        for dueTime: S.SchedulerTimeType.Stride,
        scheduler: S,
        options: S.SchedulerOptions? = nil,
        prepend: Output
    ) -> some Publisher<Output, Failure> {
        self
            .dropFirst()
            .debounce(for: .milliseconds(300), scheduler: scheduler, options: options)
            .prepend(prepend)
    }
}
