//
//  PictureGridView.swift
//  SoundBytePhotos
//
//  Created by Nicholas Boleky on 8/25/25.
//

import SwiftUI

struct PictureGridView: View {
    private let images: [Image] = []
    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                Text("Test")
                LazyVGrid(columns: gridColumns, spacing: 16) {
//                    ForEach(images, id: \.self) { image in
//                        //build item for grid here.
//                    }
                }
            }
        }
    }
        
}

#Preview {
    PictureGridView()
}
