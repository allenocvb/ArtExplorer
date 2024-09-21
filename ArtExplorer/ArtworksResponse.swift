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
    let labeltext: String?
    let commentary: String?
    let period: String?
    let medium: String?
    let technique: String?
    let culture: String?
    let classification: String?
    let dated: String?
    let images: [ArtworkImage]?
    let people: [ArtistInfo]?
    let department: String?
    let places: [Place]?
    
    var imageUrl: URL? {
        guard let urlString = primaryimageurl else { return nil }
        return URL(string: urlString)
    }
    
    var fullDescription: String {
        [description, labeltext, commentary].compactMap { $0 }.joined(separator: "\n\n")
    }
}

struct ArtworkImage: Codable {
    let baseimageurl: String?
    let iiifbaseuri: String?
}

struct ArtistInfo: Codable {
    let name: String
    let role: String
}

struct Place: Codable {
    let displayname: String
    let confidence: String?
    let placeid: Int
    let type: String
}

// Remove the GeoCoordinate struct as it's no longer needed

extension Artwork {
    static var sampleArtwork: Artwork {
        Artwork(
            id: 1,
            title: "Sample Artwork",
            description: "This is a sample artwork description.",
            primaryimageurl: "https://example.com/sample.jpg",
            labeltext: "Sample label text",
            commentary: "Sample commentary about the artwork",
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
            ],
            people: [
                ArtistInfo(name: "John Doe", role: "Artist"),
                ArtistInfo(name: "Jane Smith", role: "Artist")
            ],
            department: "Modern and Contemporary Art",
            places: [
                Place(displayname: "Sample Place", confidence: nil, placeid: 1, type: "Creation Place")
            ]
        )
    }
}
