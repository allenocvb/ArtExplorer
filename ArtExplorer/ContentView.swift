//
//  ContentView.swift
//  ArtExplorer
//
//  Created by Allen Odoom on 9/20/24.
//

import SwiftUI

struct ContentView: View {
    @State private var artworks: [Artwork] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingFilters = false
    @State private var culture = "Any"
    @State private var century = "Any"
    @State private var classification = "Any"
    @State private var isRandom = false

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading...")
                } else if let errorMessage = errorMessage {
                    Text("Error: \(errorMessage)")
                } else if artworks.isEmpty {
                    Text("No artworks found.")
                } else {
                    List {
                        ForEach(artworks) { artwork in
                            NavigationLink(destination: ArtworkDetailView(artwork: artwork)) {
                                ArtworkRow(artwork: artwork)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Art Explorer")
            .toolbar {
                Button("Filter") {
                    showingFilters = true
                }
            }
            .sheet(isPresented: $showingFilters) {
                FilterView(isPresented: $showingFilters, applyFilters: applyFilters)
            }
            .onAppear {
                fetchArtworks()
            }
        }
    }

    private func applyFilters(culture: String, century: String, classification: String, isRandom: Bool) {
        self.culture = culture
        self.century = century
        self.classification = classification
        self.isRandom = isRandom
        fetchArtworks()
    }

    private func fetchArtworks(retryCount: Int = 3) {
        isLoading = true
        errorMessage = nil
        
        let apiKey = "316f062f-548c-4bf9-b3a4-f958c902cbe8"
        
        var urlString = "https://api.harvardartmuseums.org/object?apikey=\(apiKey)&size=50"
        
        if culture != "Any" {
            urlString += "&culture=\(culture)"
        }
        if century != "Any" {
            urlString += "&century=\(century)"
        }
        if classification != "Any" {
            urlString += "&classification=\(classification)"
        }
        if isRandom {
            urlString += "&sort=random"
        }
        
        
        guard let url = URL(string: urlString) else {
                errorMessage = "Invalid URL"
                isLoading = false
                return
            }
        
        print("Fetching from URL: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
                DispatchQueue.main.async {
                    if let error = error {
                        print("Error: \(error.localizedDescription)")
                        if retryCount > 0 {
                            print("Retrying... (\(retryCount) attempts left)")
                            self.fetchArtworks(retryCount: retryCount - 1)
                        } else {
                            self.isLoading = false
                            self.errorMessage = error.localizedDescription
                        }
                    } else if let data = data {
                        do {
                            let artworksResponse = try JSONDecoder().decode(ArtworksResponse.self, from: data)
                            self.artworks = artworksResponse.records
                            self.isLoading = false
                            print("Fetched \(self.artworks.count) artworks")
                        } catch {
                            print("Decoding error: \(error)")
                            if let responseString = String(data: data, encoding: .utf8) {
                                print("Raw response: \(responseString)")
                            }
                            if retryCount > 0 {
                                print("Retrying... (\(retryCount) attempts left)")
                                self.fetchArtworks(retryCount: retryCount - 1)
                            } else {
                                self.isLoading = false
                                self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                            }
                        }
                    }
                }
            }.resume()
    }
}

struct ArtworkRow: View {
    let artwork: Artwork
    
    var body: some View {
        HStack {
            AsyncImage(url: artwork.imageUrl) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipped()
            } placeholder: {
                Color.gray
                    .frame(width: 50, height: 50)
            }
            
            VStack(alignment: .leading) {
                Text(artwork.title)
                    .font(.headline)
                if let culture = artwork.culture {
                    Text(culture)
                        .font(.subheadline)
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
