//
//  ArtworkDetailView.swift
//  ArtExplorer
//
//  Created by Allen Odoom on 9/20/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct ArtworkDetailView: View {
    let artwork: Artwork

    @State private var coordinate = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    @State private var hasCoordinate = false
    @State private var locationStatus = "Fetching location..."

    // For earlier iOS versions
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
    )

    // For iOS 17 and later
    @State private var cameraPosition = MapCameraPosition.region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 100, longitudeDelta: 100)
        )
    )

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Images
                if let images = artwork.images, !images.isEmpty {
                    ImageSlider(images: images)
                        .frame(height: 300)
                } else if let primaryImageUrl = artwork.primaryimageurl, let url = URL(string: primaryImageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray)
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(height: 300)
                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(.gray)
                        .frame(height: 300)
                }

                // Title
                Text(artwork.title)
                    .font(.title)
                    .padding(.horizontal)

                // Description
                if !artwork.fullDescription.isEmpty {
                    Text(artwork.fullDescription)
                        .font(.body)
                        .padding(.horizontal)
                }

                // Other artwork details
                if let artists = artwork.people, !artists.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Artists:")
                            .font(.headline)
                        ForEach(artists, id: \.name) { artist in
                            Text("\(artist.role ?? "Unknown Role"): \(artist.name ?? "Unknown Name")")
                        }
                    }
                    .padding(.horizontal)
                }

                if let department = artwork.department {
                    Text("Department: \(department)")
                        .font(.subheadline)
                        .padding(.horizontal)
                }

                if let culture = artwork.culture {
                    Text("Culture: \(culture)")
                        .font(.subheadline)
                        .padding(.horizontal)
                }

                if let classification = artwork.classification {
                    Text("Classification: \(classification)")
                        .font(.subheadline)
                        .padding(.horizontal)
                }

                if let dated = artwork.dated {
                    Text("Date: \(dated)")
                        .font(.subheadline)
                        .padding(.horizontal)
                }

                if let period = artwork.period {
                    Text("Period: \(period)")
                        .font(.subheadline)
                        .padding(.horizontal)
                }

                if let medium = artwork.medium {
                    Text("Medium: \(medium)")
                        .font(.subheadline)
                        .padding(.horizontal)
                }

                // Location
                VStack(alignment: .leading) {
                    Text("Location:")
                        .font(.headline)
                    Text(locationStatus)
                        .font(.subheadline)
                }
                .padding(.horizontal)

                // Map
                if hasCoordinate {
                    let annotations = [ArtworkAnnotation(coordinate: coordinate)]
                    if #available(iOS 17.0, *) {
                        Map(position: $cameraPosition) {
                            ForEach(annotations) { annotation in
                                Annotation(annotation.id.uuidString, coordinate: annotation.coordinate) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.red)
                                }
                            }
                        }
                        .frame(height: 300)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    } else {
                        Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
                            MapAnnotation(coordinate: annotation.coordinate) {
                                Image(systemName: "mappin.circle.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                            }
                        }
                        .frame(height: 300)
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            fetchPlaceDetails()
        }
        .navigationTitle("Artwork Details")
    }

    // MARK: - Fetch Place Details Function

    private func fetchPlaceDetails() {
        guard let place = artwork.places?.first else {
            locationStatus = "No location data available"
            return
        }

        if let placeName = place.name {
            geocodePlaceName(placeName)
        } else {
            locationStatus = "Location name not available"
        }
    }

    private func geocodePlaceName(_ placeName: String) {
        if let hardcodedCoordinate = getHardcodedCoordinate(for: placeName) {
            print("Using hardcoded coordinate for \(placeName)")
            DispatchQueue.main.async {
                self.updateMapWithCoordinate(hardcodedCoordinate)
                self.locationStatus = "Location found: \(placeName)"
            }
            return
        }

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(placeName) { placemarks, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Geocoding error: \(error.localizedDescription)")
                    self.locationStatus = "Couldn't find location: \(placeName)"
                    return
                }
                if let placemark = placemarks?.first,
                   let location = placemark.location {
                    let coordinate = location.coordinate
                    print("Geocoded \(placeName) to coordinates: \(coordinate.latitude), \(coordinate.longitude)")
                    self.updateMapWithCoordinate(coordinate)
                    self.locationStatus = "Location found: \(placeName)"
                } else {
                    print("No coordinates found for \(placeName)")
                    self.locationStatus = "Couldn't find location: \(placeName)"
                }
            }
        }
    }

    private func getHardcodedCoordinate(for placeName: String) -> CLLocationCoordinate2D? {
        let predefinedLocations: [String: CLLocationCoordinate2D] = [
                "China": CLLocationCoordinate2D(latitude: 35.8617, longitude: 104.1954),
                "Henan province": CLLocationCoordinate2D(latitude: 34.765, longitude: 113.7536),
                "Beijing": CLLocationCoordinate2D(latitude: 39.9042, longitude: 116.4074),
                "Shanghai": CLLocationCoordinate2D(latitude: 31.2304, longitude: 121.4737),
                "United States": CLLocationCoordinate2D(latitude: 37.0902, longitude: -95.7129),
                "New York": CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
                "Los Angeles": CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437),
                "Chicago": CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298),
                "Washington D.C.": CLLocationCoordinate2D(latitude: 38.9072, longitude: -77.0369),
                "Boston": CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589),
                "Massachusetts": CLLocationCoordinate2D(latitude: 42.4072, longitude: -71.3824),
                "Japan": CLLocationCoordinate2D(latitude: 36.2048, longitude: 138.2529),
                "Tokyo": CLLocationCoordinate2D(latitude: 35.6762, longitude: 139.6503),
                "Kyoto": CLLocationCoordinate2D(latitude: 35.0116, longitude: 135.7681),
                "India": CLLocationCoordinate2D(latitude: 20.5937, longitude: 78.9629),
                "New Delhi": CLLocationCoordinate2D(latitude: 28.6139, longitude: 77.2090),
                "Mumbai": CLLocationCoordinate2D(latitude: 19.0760, longitude: 72.8777),
                "United Kingdom": CLLocationCoordinate2D(latitude: 55.3781, longitude: -3.4360),
                "London": CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278),
                "France": CLLocationCoordinate2D(latitude: 46.2276, longitude: 2.2137),
                "Paris": CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522),
                "Germany": CLLocationCoordinate2D(latitude: 51.1657, longitude: 10.4515),
                "Berlin": CLLocationCoordinate2D(latitude: 52.5200, longitude: 13.4050),
                "Italy": CLLocationCoordinate2D(latitude: 41.8719, longitude: 12.5674),
                "Rome": CLLocationCoordinate2D(latitude: 41.9028, longitude: 12.4964),
                "Spain": CLLocationCoordinate2D(latitude: 40.4637, longitude: -3.7492),
                "Madrid": CLLocationCoordinate2D(latitude: 40.4168, longitude: -3.7038),
                "Russia": CLLocationCoordinate2D(latitude: 61.5240, longitude: 105.3188),
                "Moscow": CLLocationCoordinate2D(latitude: 55.7558, longitude: 37.6173),
                "Brazil": CLLocationCoordinate2D(latitude: -14.2350, longitude: -51.9253),
                "Rio de Janeiro": CLLocationCoordinate2D(latitude: -22.9068, longitude: -43.1729),
                "Egypt": CLLocationCoordinate2D(latitude: 26.8206, longitude: 30.8025),
                "Cairo": CLLocationCoordinate2D(latitude: 30.0444, longitude: 31.2357),
                "Greece": CLLocationCoordinate2D(latitude: 39.0742, longitude: 21.8243),
                "Athens": CLLocationCoordinate2D(latitude: 37.9838, longitude: 23.7275),
                "Mexico": CLLocationCoordinate2D(latitude: 23.6345, longitude: -102.5528),
                "Mexico City": CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
                "Canada": CLLocationCoordinate2D(latitude: 56.1304, longitude: -106.3468),
                "Toronto": CLLocationCoordinate2D(latitude: 43.6532, longitude: -79.3832),
                "Australia": CLLocationCoordinate2D(latitude: -25.2744, longitude: 133.7751),
                "Sydney": CLLocationCoordinate2D(latitude: -33.8688, longitude: 151.2093),
                "South Africa": CLLocationCoordinate2D(latitude: -30.5595, longitude: 22.9375),
                "Cape Town": CLLocationCoordinate2D(latitude: -33.9249, longitude: 18.4241),
                "Argentina": CLLocationCoordinate2D(latitude: -38.4161, longitude: -63.6167),
                "Buenos Aires": CLLocationCoordinate2D(latitude: -34.6037, longitude: -58.3816),
                "Netherlands": CLLocationCoordinate2D(latitude: 52.1326, longitude: 5.2913),
                "Amsterdam": CLLocationCoordinate2D(latitude: 52.3676, longitude: 4.9041),
                "Sweden": CLLocationCoordinate2D(latitude: 60.1282, longitude: 18.6435),
                "Stockholm": CLLocationCoordinate2D(latitude: 59.3293, longitude: 18.0686),
                "Turkey": CLLocationCoordinate2D(latitude: 38.9637, longitude: 35.2433),
                "Istanbul": CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784),
                "Israel": CLLocationCoordinate2D(latitude: 31.0461, longitude: 34.8516),
                "Jerusalem": CLLocationCoordinate2D(latitude: 31.7683, longitude: 35.2137),
                "South Korea": CLLocationCoordinate2D(latitude: 35.9078, longitude: 127.7669),
                "Seoul": CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
                "Thailand": CLLocationCoordinate2D(latitude: 15.8700, longitude: 100.9925),
                "Bangkok": CLLocationCoordinate2D(latitude: 13.7563, longitude: 100.5018),
                "Vietnam": CLLocationCoordinate2D(latitude: 14.0583, longitude: 108.2772),
                "Hanoi": CLLocationCoordinate2D(latitude: 21.0285, longitude: 105.8542),
                "Peru": CLLocationCoordinate2D(latitude: -9.1900, longitude: -75.0152),
                "Lima": CLLocationCoordinate2D(latitude: -12.0464, longitude: -77.0428),
                "Colombia": CLLocationCoordinate2D(latitude: 4.5709, longitude: -74.2973),
                "Bogotá": CLLocationCoordinate2D(latitude: 4.7110, longitude: -74.0721),
            ]
        
        for (key, coordinate) in predefinedLocations {
            if placeName.lowercased().contains(key.lowercased()) {
                return coordinate
            }
        }
        return nil
    }

    private func updateMapWithCoordinate(_ coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        self.hasCoordinate = true
        let newRegion = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 5, longitudeDelta: 5)
        )
        self.region = newRegion
        if #available(iOS 17.0, *) {
            self.cameraPosition = .region(newRegion)
        }
    }
}

struct ArtworkAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
// MARK: - ImageSlider View

struct ImageSlider: View {
    let images: [ArtworkImage]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            HStack(spacing: 10) {
                ForEach(images.indices, id: \.self) { index in
                    let image = images[index]
                    if let imageUrl = image.baseimageurl, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .failure:
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(width: 280, height: 280)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Preview Provider

struct ArtworkDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ArtworkDetailView(artwork: Artwork.sampleArtwork)
    }
}




