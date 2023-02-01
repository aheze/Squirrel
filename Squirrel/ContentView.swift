//
//  ContentView.swift
//  Squirrel
//
//  Created by A. Zheng (github.com/aheze) on 1/31/23.
//  Copyright © 2023 A. Zheng. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State var expand = false
    
    var body: some View {
        Text("Hi!")
            .frame(maxWidth: .infinity)
            .frame(height: expand ? 400 : 200)
            .background(Color.blue)
            .onTapGesture {
                withAnimation {
                    expand.toggle()
                }
            }
    }
}
