//
//  SendableBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Sean Veal on 12/17/22.
//

import SwiftUI

actor CurrentUserManager {
    func updateDatabase(userInfo: MyClassUserInfo) {
        
    }
}

struct MyUserInfo: Sendable {
    let name: String
}

final class MyClassUserInfo: @unchecked Sendable {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}

class SendableBootcampViewModel: ObservableObject {
    let manager = CurrentUserManager()
    
    func updateCurrentUserInfo() async {
        let info = MyClassUserInfo(name: "Dang")
        await manager.updateDatabase(userInfo: info)
    }
    
}

struct SendableBootcamp: View {
    
    @StateObject private var viewModel = SendableBootcampViewModel()
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .task {
                
            }
    }
}

struct SendableBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        SendableBootcamp()
    }
}
