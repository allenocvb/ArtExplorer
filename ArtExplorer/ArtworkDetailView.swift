//
//  ArtworkDetailView.swift
//  ArtExplorer
//
//  Created by Allen Odoom on 9/20/24.
//

import SwiftUI


struct ArtworkDetailView: View {
    let artwork: Artwork
    
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
                
                if let description = artwork.description {
                    Text(description)
                        .font(.body)
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
