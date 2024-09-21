//
//  FilterViewModel.swift
//  ArtExplorer
//
//  Created by Allen Odoom on 9/21/24.
//

import Foundation
import Combine
import SwiftUI

struct CultureResponse: Codable {
    let info: CultureInfo
    let records: [Culture]
}

struct CultureInfo: Codable {
    let totalrecords: Int
}

struct Culture: Codable, Identifiable {
    let id: Int
    let name: String
}

class FilterViewModel: ObservableObject {
    @Published var selectedCulture: String = "Any"
    @Published var selectedCentury: String = "Any"
    @Published var selectedClassification: String = "Any"
    @Published var isRandom: Bool = false
    @Published var cultures: [String] = ["Any"]
    
    @Published var appliedFilters: (culture: String, century: String, classification: String, isRandom: Bool) = ("Any", "Any", "Any", false)
    
    private var cancellables = Set<AnyCancellable>()
    private let apiKey = "316f062f-548c-4bf9-b3a4-f958c902cbe8"
    
    init() {
        Publishers.CombineLatest4($selectedCulture, $selectedCentury, $selectedClassification, $isRandom)
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] culture, century, classification, isRandom in
                self?.applyFilters(culture: culture, century: century, classification: classification, isRandom: isRandom)
            }
            .store(in: &cancellables)
        
        fetchCultures()
    }
    

    func applyFilters(culture: String, century: String, classification: String, isRandom: Bool) {
            print("Applying filters: culture: \(culture), century: \(century), classification: \(classification), isRandom: \(isRandom)")
            appliedFilters = (culture, century, classification, isRandom)
        }
    
    private func fetchCultures() {
        let urlString = "https://api.harvardartmuseums.org/culture?apikey=\(apiKey)&size=200"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error fetching cultures: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    print("No data received")
                    return
                }
                
                do {
                    let cultureResponse = try JSONDecoder().decode(CultureResponse.self, from: data)
                    self?.cultures = ["Any"] + cultureResponse.records.map { $0.name }.sorted()
                } catch {
                    print("Decoding error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}
