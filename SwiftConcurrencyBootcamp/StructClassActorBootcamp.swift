//
//  StructClassActorBootcamp.swift
//  SwiftConcurrencyBootcamp
//
//  Created by Sean Veal on 12/16/22.
//

import SwiftUI

struct StructClassActorBootcamp: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .onAppear {
                runTest()
                actorTest1()
            }
    }
}

struct StructClassActorBootcamp_Previews: PreviewProvider {
    static var previews: some View {
        StructClassActorBootcamp()
    }
}

struct MyStruct {
    var title: String
    
    // change the property from var to let
    func updateTitle(_ title: String) -> MyStruct {
        MyStruct(title: title)
    }
}

actor MyActor {
    var title: String
    
    init(title: String) {
        self.title = title
    }
    
    func updateTitle(_ title: String) {
        self.title = title
    }
}

extension StructClassActorBootcamp {
    private func runTest() {
        print("Test Started!")
    }
    
    private func structTest1() {
        let objectA = MyStruct(title: "Starting Title!")
        print("Object A: ", objectA.title)
        
        var objectB = objectA
        print("Object B: ", objectB.title)
        
        objectB.title = "Second Title"
    }
    
    private func actorTest1() {
        Task {
            print("actorTest1")
            let objectA = MyActor(title: "Starting Title!")
            await print("ObjectA: ", objectA.title)
            
            print("Pass the REFERENCE of objectA to objectB.")
            let objectB = objectA
            await print("ObjectB: ", objectB.title)
            
            await objectB.updateTitle("Second Title")
            print("ObjectB title changed.")
            
            await print("ObjectA: ", objectA.title)
            await print("ObjectB: ", objectB.title)
        }
    }
}
