//
//  TaskBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Sean Veal on 12/16/22.
//

import SwiftUI

class TaskBootcampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    @Published var image2: UIImage? = nil
    
    func fetchImage() async {
        try? await Task.sleep(nanoseconds: 5_000_000_000)
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                self.image = UIImage(data: data)
                print("IMAGE RETURNED")
            })
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func fetchImage2() async {
        do {
            guard let url = URL(string: "https://picsum.photos/200") else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            await MainActor.run(body: {
                self.image2 = UIImage(data: data)
            })
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct TaskBootcampHomeView: View {
    var body: some View {
        NavigationView {
            ZStack {
                NavigationLink("Click Me! 🤓") {
                    TaskBootcamp()
                }
            }
        }
    }
}

struct TaskBootcamp: View {
    @StateObject private var viewModel = TaskBootcampViewModel()
    @State private var fetchImageTask: Task<Void, Never>? = nil
    var body: some View {
        VStack(spacing: 40) {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
            
            if let image = viewModel.image2 {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
            await viewModel.fetchImage()
        }
//        .onDisappear(perform: {
//            fetchImageTask?.cancel()
//        })
//        .onAppear {
//            fetchImageTask = Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage()
//            }
//            Task {
//                print(Thread.current)
//                print(Task.currentPriority)
//                await viewModel.fetchImage2()
//            }
//            Task(priority: .high) {
////                try? await Task.sleep(nanoseconds: 2_000_000_000)
//                await Task.yield()
//                print("HIGH: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .userInitiated) {
//                print("USER: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .medium) {
//                print("MEDIUM: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .low) {
//                print("LOW: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .utility) {
//                print("UTILITY: \(Thread.current) : \(Task.currentPriority)")
//            }
//            Task(priority: .background) {
//                print("BACKGROUND: \(Thread.current) : \(Task.currentPriority)")
//            }
            
//            Task(priority: .userInitiated) {
//                print("USER: \(Thread.current) : \(Task.currentPriority)")
//
//                Task.detached {
//                    print("USER2: \(Thread.current) : \(Task.currentPriority)")
//                }
//            }
//        }
    }
}

struct TaskBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        TaskBootcamp()
    }
}
