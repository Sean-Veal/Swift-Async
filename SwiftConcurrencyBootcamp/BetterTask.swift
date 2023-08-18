//
//  BetterTask.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Sean Veal on 8/17/23.
//

import SwiftUI

class BetterTaskViewModel: ObservableObject {
    
    var text: String? = nil
    
    let basicTask = Task {
        return "This is the result of the Task"
    }
    
    let errorTask = Task {
        throw URLError(.badServerResponse)
    }
    
    let tryCancelTask = Task {
        try await Task.sleep(nanoseconds: 1_000_000_000)
        try Task.checkCancellation()
        print("Got the String")
    }
    
    func getValue() async {
        print(await basicTask.value)
    }
    
    func getErrorTask() async {
        do {
            try await errorTask.value
        } catch {
            print("Error: \(error)")
        }
    }
    
    func cancelTask() async {
        do {
            tryCancelTask.cancel()
            try await tryCancelTask.value
        } catch {
            print("Error: \(error)")
        }
        
    }
    
}

struct BetterTask: View {
    @State private var vm = BetterTaskViewModel()
    
    var body: some View {
        Group {
            if vm.text == nil {
                ProgressView()
            } else {
                Text(vm.text ?? "Empty")
            }
        }
        .task {
            await vm.getValue()
            await vm.getErrorTask()
            await vm.cancelTask()
        }
    }
}

#Preview {
    BetterTask()
}
