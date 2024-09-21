//
//  CultureCache.swift
//  ArtExplorer
//
//  Created by Allen Odoom on 9/21/24.
//

import Foundation


class CultureCache {
    static let shared = CultureCache()
    private let defaults = UserDefaults.standard
    private let culturesCacheKey = "cachedCultures"
    private let lastFetchDateKey = "lastCulturesFetchDate"
    
    func getCachedCultures() -> [String]? {
        guard let data = defaults.data(forKey: culturesCacheKey),
              let cultures = try? JSONDecoder().decode([String].self, from: data) else {
            return nil
        }
        return cultures
    }
    
    func setCachedCultures(_ cultures: [String]) {
        if let encoded = try? JSONEncoder().encode(cultures) {
            defaults.set(encoded, forKey: culturesCacheKey)
            defaults.set(Date(), forKey: lastFetchDateKey)
        }
    }
    
    func shouldFetchCultures() -> Bool {
        guard let lastFetchDate = defaults.object(forKey: lastFetchDateKey) as? Date else {
            return true
        }
        return Date().timeIntervalSince(lastFetchDate) > 7 * 24 * 60 * 60 // 7 days
    }
}
