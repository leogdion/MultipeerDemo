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
            Button("Start") {
                self.object.start()
            }
            Button("Stop") {
                self.object.stop()
            }
        }
            .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
