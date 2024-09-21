//
//  ArtworksResponse.swift
//  ArtExplorer
//
//  Created by Allen Odoom on 9/20/24.
//

import Foundation

struct ArtworksResponse: Codable {
    let info: Info
    let records: [Artwork]
}

struct Info: Codable {
    let totalrecordsperquery: Int
    let totalrecords: Int
    let pages: Int
    let page: Int
}

struct Artwork: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String?
    let primaryimageurl: String?
    let period: String?
    let medium: String?
    let technique: String?
    let culture: String?
    let classification: String?
    let dated: String?
    let images: [ArtworkImage]?
    
    var imageUrl: URL? {
        guard let urlString = primaryimageurl else { return nil }
        return URL(string: urlString)
    }
}

struct ArtworkImage: Codable {
    let baseimageurl: String?
    let iiifbaseuri: String?
}

extension Artwork {
    static var sampleArtwork: Artwork {
        Artwork(
            id: 1,
            title: "Sample Artwork",
            description: "This is a sample artwork description.",
            primaryimageurl: "https://example.com/sample.jpg",
            period: "Modern",
            medium: "Oil on canvas",
            technique: "Brushwork",
            culture: "American",
            classification: "Painting",
            dated: "2024",
            images: [
                ArtworkImage(
                    baseimageurl: "https://example.com/sample.jpg",
                    iiifbaseuri: "https://example.com/iiif/sample"
                )
            ]
        )
    }
}
