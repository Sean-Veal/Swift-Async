//
//  CheckedContinuationBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Sean Veal on 12/16/22.
//

import SwiftUI

class CheckedContinuationBootcampNetworkManager {
    
    func getData(url: URL) async throws -> Data {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        } catch  {
            throw error
        }
    }
    
    func getData2(url: URL) async throws -> Data {
        return try await withCheckedThrowingContinuation({ continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data {
                    continuation.resume(returning: data)
                } else if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(throwing: URLError(.badURL))
                }
            }
            .resume()
        })
    }
    
    func getHeartImageFromDatabase(completionHandler: @escaping (_ image: UIImage) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            completionHandler(UIImage(systemName: "heart.fill")!)
        }
    }
    
    func getHeartImageFromDatabase() async -> UIImage {
        return await withCheckedContinuation({ continuation in
            getHeartImageFromDatabase { image in
                continuation.resume(returning: image)
            }
        })
    }
}

class CheckedContinuationBootcampViewModel: ObservableObject {
    @Published var image: UIImage? = nil
    let manager = CheckedContinuationBootcampNetworkManager()
    
    func getImage() async {
        guard let url = URL(string: "https://picsum.photos/300") else { return }
        do {
            let data = try await manager.getData2(url: url)
            if let image = UIImage(data: data) {
                await MainActor.run(body: {
                    self.image = image
                })
            }
        } catch  {
            print(error.localizedDescription)
        }
    }
    
    func getHeartImage() async {
        let image = await manager.getHeartImageFromDatabase()
        await MainActor.run(body: {
            self.image = image
        })
    }
}

struct CheckedContinuationBootcamp: View {
    @StateObject private var viewModel = CheckedContinuationBootcampViewModel()
    var body: some View {
        ZStack {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
            }
        }
        .task {
//            await viewModel.getImage()
            await viewModel.getHeartImage()
        }
    }
}

struct CheckedContinuationBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        CheckedContinuationBootcamp()
    }
}
