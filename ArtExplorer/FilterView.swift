//
//  FilterView.swift
//  ArtExplorer
//
//  Created by Allen Odoom on 9/20/24.
//

import SwiftUI

struct FilterView: View {
    @ObservedObject var viewModel: FilterViewModel
    @Binding var isPresented: Bool
    
    let centuries = ["Any", "21st", "20th", "19th", "18th", "17th", "16th", "15th", "14th", "13th", "12th", "11th", "10th"]
    let classifications = ["Any", "Paintings", "Photographs", "Prints", "Sculpture", "Textile Arts", "Vessels", "Coins", "Jewelry"]

    var body: some View {
        NavigationView {
            Form {
                Picker("Culture", selection: $viewModel.selectedCulture) {
                    ForEach(viewModel.cultures, id: \.self) { culture in
                        Text(culture)
                    }
                }

                Picker("Century", selection: $viewModel.selectedCentury) {
                    ForEach(centuries, id: \.self) { century in
                        Text(century)
                    }
                }

                Picker("Classification", selection: $viewModel.selectedClassification) {
                    ForEach(classifications, id: \.self) { classification in
                        Text(classification)
                    }
                }

                Toggle("Random Selection", isOn: $viewModel.isRandom)

                Button("Apply Filters") {
                    print("Before applying filters - isRandom: \(viewModel.isRandom)")
                    viewModel.applyFilters(
                        culture: viewModel.selectedCulture,
                        century: viewModel.selectedCentury,
                        classification: viewModel.selectedClassification,
                        isRandom: viewModel.isRandom
                    )
                    isPresented = false
                }
            }
            .navigationTitle("Filter Artworks")
            .toolbar {
                Button("Close") {
                    isPresented = false
                }
            }
        }
    }
}

