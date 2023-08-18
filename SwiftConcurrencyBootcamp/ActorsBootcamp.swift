//
//  ActorsBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Sean Veal on 12/17/22.
//

import SwiftUI

// 1. What is the problem that actors are solving
// 2. How was this problem solved prior to actors
// 3. Actors can solve the problem

class MyDataManager {
    static let instance = MyDataManager()
    
    private init() { }
    
    var data: [String] = []
    private let lock = DispatchQueue(label: "com.myapp.MyDataManager")
    
    func getRandomData(completionHandler: @escaping (_ title: String?) -> Void) {
        lock.async {
            self.data.append(UUID().uuidString)
            print("Thread: \(Thread.current)")
            completionHandler(self.data.randomElement())
        }
        
    }
}

actor MyActorDataManager {
    static let instance = MyActorDataManager()
    
    private init() { }
    
    var data: [String] = []
    
    nonisolated
    let dude = "DUDE"
    
    func getRandomData() -> String? {
            self.data.append(UUID().uuidString)
            print("Thread: \(Thread.current)")
            return self.data.randomElement()
    }
    
    nonisolated
    func getString() -> String {
        return "NEW STRING!"
    }
}

struct HomeView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        ZStack {
            Color.gray.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onAppear(perform: {
            
        })
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
//            DispatchQueue.global(qos: .background).async {
//
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
            
        }
    }
}

struct BrowseView: View {
    
    let manager = MyActorDataManager.instance
    @State private var text: String = ""
    let timer = Timer.publish(every: 0.01, on: .main, in: .common).autoconnect()

    
    var body: some View {
        ZStack {
            Color.yellow.opacity(0.8).ignoresSafeArea()
            
            Text(text)
                .font(.headline)
        }
        .onReceive(timer) { _ in
            Task {
                if let data = await manager.getRandomData() {
                    await MainActor.run(body: {
                        self.text = data
                    })
                }
            }
//            DispatchQueue.global(qos: .background).async {
//                manager.getRandomData { title in
//                    if let data = title {
//                        DispatchQueue.main.async {
//                            self.text = data
//                        }
//                    }
//                }
//            }
        }
    }
}

struct ActorsBootcamp: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            BrowseView()
                .tabItem {
                    Label("Browse", systemImage: "magnifyingglass")
                }
        }
    }
}

struct ActorsBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        ActorsBootcamp()
    }
}
