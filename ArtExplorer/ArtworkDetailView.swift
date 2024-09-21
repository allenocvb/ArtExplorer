//
//  ArtworkDetailView.swift
//  ArtExplorer
//
//  Created by Allen Odoom on 9/20/24.
//

import SwiftUI
import MapKit

struct ArtworkDetailView: View {
    let artwork: Artwork
    @State private var region: MKCoordinateRegion
    
    init(artwork: Artwork) {
        self.artwork = artwork
        
        // Don't have direct lat/lon, can use a default or random location for now
        let coordinate = CLLocationCoordinate2D(latitude: Double.random(in: -90...90), longitude: Double.random(in: -180...180))
        
        _region = State(initialValue: MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let images = artwork.images, !images.isEmpty {
                    ImageSlider(images: images)
                        .frame(height: 300)
                } else {
                    Color.gray
                        .frame(height: 300)
                }
                
                Text(artwork.title)
                    .font(.title)
                
                if !artwork.fullDescription.isEmpty {
                    Text(artwork.fullDescription)
                        .font(.body)
                }
                
                if let artists = artwork.people, !artists.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Artists:")
                            .font(.headline)
                        ForEach(artists, id: \.name) { artist in
                            Text("\(artist.role): \(artist.name)")
                        }
                    }
                }
                
                if let department = artwork.department {
                    Text("Department: \(department)")
                        .font(.subheadline)
                }
                
                if let culture = artwork.culture {
                    Text("Culture: \(culture)")
                        .font(.subheadline)
                }
                
                if let classification = artwork.classification {
                    Text("Classification: \(classification)")
                        .font(.subheadline)
                }
                
                if let dated = artwork.dated {
                    Text("Date: \(dated)")
                        .font(.subheadline)
                }
                
                if let period = artwork.period {
                    Text("Period: \(period)")
                        .font(.subheadline)
                }
                
                if let medium = artwork.medium {
                    Text("Medium: \(medium)")
                        .font(.subheadline)
                }
                
                VStack(alignment: .leading) {
                    Text("Location:")
                        .font(.headline)
                    if let place = artwork.places?.first {
                        Text(place.displayname)
                            .font(.subheadline)
                    } else {
                        Text("No location data available.")
                            .font(.subheadline)
                    }
                }
                
                Map(coordinateRegion: $region, annotationItems: [artwork]) { artwork in
                    MapMarker(coordinate: region.center, tint: .red)
                }
                .frame(height: 300)
                .cornerRadius(12)
            }
            .padding()
        }
        .navigationTitle("Artwork Details")
    }
}

struct ImageSlider: View {
    let images: [ArtworkImage]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(images, id: \.iiifbaseuri) { image in
                    AsyncImage(url: URL(string: image.baseimageurl ?? "")) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Image(systemName: "photo")
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(width: 280, height: 280)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                }
            }
            .padding()
        }
    }
}

struct ArtworkDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ArtworkDetailView(artwork: Artwork.sampleArtwork)
    }
}
