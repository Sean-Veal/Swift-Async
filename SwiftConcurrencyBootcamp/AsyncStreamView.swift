//
//  AsyncStreamView.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Sean Veal on 8/17/23.
//

import SwiftUI
import UIKit

final class Service {
    func download(url: URL, completion: @escaping (Result<UIImage?, Error>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let data = data {
                completion(.success(UIImage(data: data)))
            } else {
                completion(.failure(error!))
            }
        }
        .resume()
    }
}

class AsyncStreamViewModel: ObservableObject {
    @Published var pic: UIImage? = nil
    
    private let urls: [URL] = [
        URL(string: "https://fastly.picsum.photos/id/22/4434/3729.jpg?hmac=fjZdkSMZJNFgsoDh8Qo5zdA_nSGUAWvKLyyqmEt2xs0")!,
        URL(string: "https://fastly.picsum.photos/id/23/3887/4899.jpg?hmac=2fo1Y0AgEkeL2juaEBqKPbnEKm_5Mp0M2nuaVERE6eE")!,
        URL(string: "https://fastly.picsum.photos/id/26/4209/2769.jpg?hmac=vcInmowFvPCyKGtV7Vfh7zWcA_Z0kStrPDW3ppP0iGI")!,
        URL(string: "https://fastly.picsum.photos/id/28/4928/3264.jpg?hmac=GnYF-RnBUg44PFfU5pcw_Qs0ReOyStdnZ8MtQWJqTfA")!,
        URL(string: "https://fastly.picsum.photos/id/41/1280/805.jpg?hmac=W9CWeYdlZisqEfhjuODl83T3lCXAqjUZrOe9iMFPYmI")!
    ]
    
    init() {
        Task {
            for try await returnedImage in downloadPhotos() {
                print("Returned Image")
                await MainActor.run {
                    self.pic = returnedImage
                }
                try await Task.sleep(nanoseconds: 2_000_000_000)
            }
        }
    }
    
    func downloadPhotos() -> AsyncThrowingStream<UIImage, Error> {
        return AsyncThrowingStream { continuation in
            let service = Service()
            for url in urls {
                service.download(url: url, completion: { result in
                    switch result {
                    case .success(let uiImage):
                        guard let image = uiImage else { continuation.finish()
                            return
                        }
                        continuation.yield(image)
                    case .failure(let error):
                        continuation.finish(throwing: error)
                    }
                })
            }
//            continuation.finish()
        }
    }
}

struct AsyncStreamView: View {
    @StateObject private var vm = AsyncStreamViewModel()
    var body: some View {
        if let image = vm.pic {
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
        } else {
            Text("Image is loading") 
        }
    }
}

#Preview {
    AsyncStreamView()
}
