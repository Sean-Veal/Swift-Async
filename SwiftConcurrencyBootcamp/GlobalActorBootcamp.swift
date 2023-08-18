//
//  GlobalActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Sean Veal on 12/17/22.
//

import SwiftUI

@globalActor final class MyFirstGlobalActor {
    static var shared = MyNewDataManager()
}

actor MyNewDataManager {
    func getDataFromDatabase() -> [String] {
        return ["one", "two", "three", "four", "five", "six"]
    }
}

@MainActor class GlobalActorBootcampViewModel: ObservableObject {
    @Published var dataArray: [String] = []
    @Published var dataArray2: [String] = []
    @Published var dataArray3: [String] = []
    @Published var dataArray4: [String] = []
    let manager = MyFirstGlobalActor.shared
    
    @MyFirstGlobalActor
    func getData() {
        
        // HEAVY COMPLEX METHODS
        Task {
            let data = await manager.getDataFromDatabase()
            await MainActor.run(body: {
                dataArray.append(contentsOf: data)
            })
            
        }
    }
}

struct GlobalActorBootcamp: View {
    @StateObject private var viewModel = GlobalActorBootcampViewModel()
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
            await viewModel.getData()
        }
    }
}

struct GlobalActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        GlobalActorBootcamp()
    }
}
