//
//  FilterView.swift
//  ArtExplorer
//
//  Created by Allen Odoom on 9/20/24.
//

import SwiftUI

struct FilterView: View {
    @State private var selectedCulture: String = "Any"
    @State private var selectedCentury: String = "Any"
    @State private var selectedClassification: String = "Any"
    @State private var isRandom: Bool = false
    @Binding var isPresented: Bool
    var applyFilters: (String, String, String, Bool) -> Void

    let cultures = ["Any", "American", "European", "Asian", "African"]
    let centuries = ["Any", "21st", "20th", "19th", "18th", "17th", "16th"]
    let classifications = ["Any", "Paintings", "Photographs", "Prints", "Sculpture", "Textile Arts"]

    var body: some View {
        NavigationView {
            Form {
                Picker("Culture", selection: $selectedCulture) {
                    ForEach(cultures, id: \.self) { culture in
                        Text(culture)
                    }
                }

                Picker("Century", selection: $selectedCentury) {
                    ForEach(centuries, id: \.self) { century in
                        Text(century)
                    }
                }

                Picker("Classification", selection: $selectedClassification) {
                    ForEach(classifications, id: \.self) { classification in
                        Text(classification)
                    }
                }

                Toggle("Random Selection", isOn: $isRandom)

                Button("Apply Filters") {
                    applyFilters(selectedCulture, selectedCentury, selectedClassification, isRandom)
                    isPresented = false
                }
            }
            .navigationTitle("Filter Artworks")
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(isPresented: .constant(true), applyFilters: { _, _, _, _ in })
    }
}


