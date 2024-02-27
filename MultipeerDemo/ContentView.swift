//
//  ContentView.swift
//  MultipeerDemo
//
//  Created by Leo on 2/27/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var object = AdvertiserManager()
    var body: some View {
        VStack{
            Text(object.id.description)
        }
            .padding()
            .onAppear {
                self.object.start()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
