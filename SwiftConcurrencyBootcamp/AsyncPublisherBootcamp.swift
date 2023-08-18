//
//  AsyncPublisherBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Sean Veal on 12/17/22.
//

import SwiftUI
import Combine

class AsyncPublisherBootcampDataManager {
    @Published var myData: [String] = []
    
    func addData() async {
        myData.append("Apple")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Banana")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Orange")
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        myData.append("Watermelon")
    }
}

class AsyncPublisherBootcampViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    let manager = AsyncPublisherBootcampDataManager()
    var cancellables = Set<AnyCancellable>()
    
    init() {
        addSubscribers()
    }
    
    func start() async {
        await manager.addData()
    }
    
    private func addSubscribers() {
        Task {
            await MainActor.run(body: {
                self.dataArray = ["One"]
            })
            
            for await value in manager.$myData.values {
                await MainActor.run(body: {
                    self.dataArray = value
                })
                // If you want code to execute outside the for loop // put break here
            }
            
            await MainActor.run(body: {
                self.dataArray = ["TWO"]
            })
        }
//        manager.$myData
//            .receive(on: DispatchQueue.main)
//            .sink { dataArray in
//                self.dataArray = dataArray
//            }
//            .store(in: &cancellables)
    }
}

struct AsyncPublisherBootcamp: View {
    @StateObject private var viewModel = AsyncPublisherBootcampViewModel()
    var body: some View {
        ScrollView {
            VStack {
                ForEach(viewModel.dataArray, id: \.self) {
                    Text($0)
                        .font(.headline)
                }
            }
        }
        .task {
            await viewModel.start()
        }
    }
}

struct AsyncPublisherBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        AsyncPublisherBootcamp()
    }
}
