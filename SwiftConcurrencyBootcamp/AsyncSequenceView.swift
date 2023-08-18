//
//  AsyncSequence.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Sean Veal on 8/17/23.
//

import SwiftUI

struct Counter: AsyncSequence {
    typealias Element = Int
    
    let limit: Int
    
    struct AsyncIterator: AsyncIteratorProtocol {
        let limit: Int
        var current = 1
        
        mutating func next() async throws -> Int? {
            guard !Task.isCancelled else { return nil }
            guard current <= limit else { return nil }
            
            let result = current
            current += 1
            return result
        }
    }
    
    func makeAsyncIterator() -> AsyncIterator {
        AsyncIterator(limit: limit)
    }
}

struct NewCounter: AsyncSequence, AsyncIteratorProtocol {
    typealias AsyncIterator = Self
    
    typealias Element = Int
    
    let limit: Int
    var current = 1
    
    mutating func next() async throws -> Int? {
        guard !Task.isCancelled else { return nil }
        guard current <= limit else { return nil }
        
        let result = current
        current += 1
        return result

    }
    
    func makeAsyncIterator() -> NewCounter {
        self
    }
}

class AsyncSequenceViewModel: ObservableObject {
    @Published var values: [Int] = []
    
    func getValues() async throws {
        for try await count in NewCounter(limit: 5) {
            values.append(count)
        }
    }
}

struct AsyncSequenceView: View {
    @StateObject private var vm = AsyncSequenceViewModel()
    
    var body: some View {
        List(vm.values, id: \.self) { value in
            Text("\(value)")
        }
        .task {
            try? await vm.getValues()
        }
    }
}

#Preview {
    AsyncSequenceView()
}
