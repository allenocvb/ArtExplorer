//
//  HomeView.swift
//  ArtExplorer
//
//  Created by Allen Odoom on 9/20/24.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Image("RenaissanceSky")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    Text("Art Explorer")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                    
                    NavigationLink(destination: ContentView()) {
                        Text("Explore Art")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

