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
    @State private var previousFilters: (culture: String, century: String, classification: String, isRandom: Bool)?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    if isLoading {
                        ProgressView("Loading...")
                    } else if let errorMessage = errorMessage {
                        Text("Error: \(errorMessage)")
                    } else if artworks.isEmpty {
                        Text("No artworks found.")
                    } else {
                        ForEach(artworks) { artwork in
                            NavigationLink(destination: ArtworkDetailView(artwork: artwork)) {
                                ArtworkRow(artwork: artwork)
                            }
                        }
                    }
                }
                .padding()
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
                if previousFilters == nil {
                    previousFilters = filterViewModel.appliedFilters
                    fetchArtworks()
                }
            }
            .onChange(of: filterViewModel.filtersChanged) { _ in
                let newFilters = filterViewModel.appliedFilters
                if !areFiltersEqual(previousFilters, newFilters) {
                    previousFilters = newFilters
                    fetchArtworks()
                }
            }
        }
    }
    
    private func areFiltersEqual(_ lhs: (culture: String, century: String, classification: String, isRandom: Bool)?,
                                 _ rhs: (culture: String, century: String, classification: String, isRandom: Bool)) -> Bool {
        guard let lhs = lhs else { return false }
        return lhs.culture == rhs.culture &&
               lhs.century == rhs.century &&
               lhs.classification == rhs.classification &&
               lhs.isRandom == rhs.isRandom
    }
    
    private func fetchArtworks() {
        isLoading = true
        errorMessage = nil
        
        let apiKey = Config.apiKey
        
        var urlString = "https://api.harvardartmuseums.org/object?apikey=\(apiKey)&size=100&fields=id,title,description,primaryimageurl,images,culture,classification,dated,period,medium,technique,department,people,places"
        
        let (culture, century, classification, isRandom) = filterViewModel.appliedFilters
        
        if !urlString.contains("sort=") {
            urlString += "&sort=random"
        }
        
        if culture == "Any" {
            // When 'Any' is selected, explicitly request a mix of cultures
            let popularCultures = ["American", "Chinese", "European", "Greek", "Roman", "Egyptian", "Japanese", "Indian"]
            let culturesToInclude = popularCultures.prefix(5).joined(separator: "|")
            urlString += "&culture=\(culturesToInclude)"
        } else {
            let encodedCulture = culture.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? culture
            urlString += "&culture=\(encodedCulture)"
        }
        
        if century != "Any" {
            let encodedCentury = century.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? century
            urlString += "&century=\(encodedCentury)"
        }
        
        if classification != "Any" {
            let encodedClassification = classification.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? classification
            urlString += "&classification=\(encodedClassification)"
        }
        
        if isRandom {
            urlString += "&sort=random"
        }
        
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                self.errorMessage = "Invalid URL"
                self.isLoading = false
            }
            return
        }
        
        print("Fetching artworks with URL: \(urlString)")
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else if let data = data {
                    do {
                        let artworksResponse = try JSONDecoder().decode(ArtworksResponse.self, from: data)
                        self.artworks = artworksResponse.records.filter { $0.primaryimageurl != nil }
                        
                        // Print out the cultures of fetched artworks for debugging
                        let cultures = self.artworks.compactMap { $0.culture }
                        print("Fetched artworks cultures: \(cultures)")
                        
                    } catch {
                        self.errorMessage = "Failed to decode response: \(error.localizedDescription)"
                        print("Decoding error: \(error)")
                    }
                }
            }
        }.resume()
    }
}

struct ArtworkRow: View {
    let artwork: Artwork
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if let imageUrl = artwork.imageUrl {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.gray)
                    @unknown default:
                        Color.gray
                    }
                }
                .frame(height: 200)
                .clipped()
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.gray)
                    .frame(height: 200)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(artwork.title)
                    .font(.headline)
                    .lineLimit(2)
                if let culture = artwork.culture {
                    Text(culture)
                        .font(.subheadline)
                        .lineLimit(1)
                }
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.7))
            .foregroundColor(.white)
        }
        .frame(height: 200)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
