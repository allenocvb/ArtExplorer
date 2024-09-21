//
//  ContentView.swift
//  ArtExplorer
//
//  Created by Allen Odoom on 9/20/24.
//

import SwiftUI
import Combine

struct ContentView: View {
    @StateObject private var filterViewModel = FilterViewModel()
    @State private var artworks: [Artwork] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingFilters = false
    
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
                FilterView(viewModel: filterViewModel, isPresented: $showingFilters)
            }
            .onAppear {
                fetchArtworks()
            }
        }
        .onReceive(filterViewModel.$selectedCulture) { _ in fetchArtworks() }
        .onReceive(filterViewModel.$selectedCentury) { _ in fetchArtworks() }
        .onReceive(filterViewModel.$selectedClassification) { _ in fetchArtworks() }
        .onReceive(filterViewModel.$isRandom) { _ in fetchArtworks() }
        .onReceive(filterViewModel.$appliedFilters) { _ in fetchArtworks() }
    }
    
    private func fetchArtworks() {
        isLoading = true
        errorMessage = nil
        
        let apiKey = "316f062f-548c-4bf9-b3a4-f958c902cbe8"
        
        var urlString = "https://api.harvardartmuseums.org/object?apikey=\(apiKey)&size=50&fields=id,title,description,primaryimageurl,images,culture,classification,dated,period,medium,technique,department,people,places"
        
        let (culture, century, classification, isRandom) = filterViewModel.appliedFilters
        
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
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let data = data {
                    // Print raw JSON data
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("Raw JSON data:")
                        print(jsonString)
                    }
                    
                    do {
                        let artworksResponse = try JSONDecoder().decode(ArtworksResponse.self, from: data)
                        self.artworks = artworksResponse.records
                        
                        // After fetching artworks, fetch place details for each
                        for artwork in self.artworks {
                            self.fetchPlaceDetails(for: artwork)
                        }
                    } catch {
                        self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                        print("Decoding error: \(error)")
                    }
                }
            }
        }.resume()
    }
    
    private func fetchPlaceDetails(for artwork: Artwork) {
        guard let place = artwork.places?.first else {
            print("Artwork: \(artwork.title) - No location data")
            return
        }
        
        let apiKey = "316f062f-548c-4bf9-b3a4-f958c902cbe8"
        let urlString = "https://api.harvardartmuseums.org/place/\(place.placeid)?apikey=\(apiKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let placeResponse = try JSONDecoder().decode(Place.self, from: data)
                    print("Artwork: \(artwork.title)")
                    print("Location: \(placeResponse.displayname)")
                } catch {
                    print("Failed to decode place response: \(error)")
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
