import Foundation
import Combine
import DashTypes

public class PersonalDataPublisher<ResultType: PersonalDataCodable>: Publisher {
    public typealias Output = Dictionary<Identifier, ResultType>.Values
    public typealias Failure = Never

    private let stack: ApplicationDBStack

    init(output: ResultType.Type, stack: ApplicationDBStack) {
        self.stack = stack
    }

    public func receive<S>(subscriber: S) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        let subscription = PersonalDataPublisherSubscription<ResultType>(stack: stack,
                                                                         receiveCompletion: subscriber.receive(completion:),
                                                                         receiveValue: subscriber.receive(_:))
        subscriber.receive(subscription: subscription)
    }
}

private class PersonalDataPublisherSubscription<ResultType: PersonalDataCodable>: Subscription {
        private enum State {
        case waitingForDemand
        case observing(PersonalDataAutoFetcher<ResultType>, AnyCancellable?, Subscribers.Demand)
        case completed
        case cancelled
    }

    private var state: State = .waitingForDemand
    private let stack: ApplicationDBStack
    private var subscription: AnyCancellable?
    private let receiveCompletion: (Subscribers.Completion<Never>) -> Void
    private let receiveValue: (PersonalDataPublisher<ResultType>.Output) -> Subscribers.Demand

    init(stack: ApplicationDBStack,
         receiveCompletion: @escaping (Subscribers.Completion<Never>) -> Void,
         receiveValue: @escaping (PersonalDataPublisher<ResultType>.Output) -> Subscribers.Demand) {
        self.stack = stack
        self.receiveCompletion = receiveCompletion
        self.receiveValue = receiveValue
    }

    func request(_ demand: Subscribers.Demand) {
                switch state {
            case .waitingForDemand:
                guard demand > 0 else {
                    return
                }

                let fetcher = PersonalDataAutoFetcher<ResultType>(stack: stack)
                let subscription = fetcher.itemsPublisher.sink { [weak self] items in
                    self?.receiveUpdatedValues(items)
                }
                state = .observing(fetcher, subscription, demand)

            case let .observing(fetcher, subscription, currentDemand):
                state = .observing(fetcher, subscription, currentDemand + demand)
            case .completed:
                break
            case .cancelled:
                break
        }
    }

    func cancel() {
        state = .cancelled
    }

    private func receiveUpdatedValues(_ items: PersonalDataPublisher<ResultType>.Output) {
        guard case let .observing(fetcher, subscription, currentDemand) = state else {
            return
        }

        let additionalDemand = receiveValue(items)

        let newDemand = currentDemand + additionalDemand - 1
        if newDemand == .none {
            state = .waitingForDemand
        } else {
            state = .observing(fetcher, subscription, newDemand)
        }
    }

    private func receiveCompletion(_ completion: Subscribers.Completion<Error>) {
        guard case .observing = state else {
            return
        }

        state = .completed
        receiveCompletion(completion)
    }
}
