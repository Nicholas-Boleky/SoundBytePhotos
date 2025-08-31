//
//  PictureGridView.swift
//  SoundBytePhotos
//
//  Created by Nicholas Boleky on 8/25/25.
//

import SwiftUI
import _PhotosUI_SwiftUI

struct PictureGridView: View {
    @StateObject private var store = MemoryStore()
    @State private var pickerItem: PhotosPickerItem?
    
    private let images: [Image] = []
    private let gridColumns: [GridItem] = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                ScrollView {
                    Text("Test")
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(store.memories) { memory in
                            ThumbTile(url: memory.thumbURL)
                        }
                    }
                    .padding()
                }
                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label("Add Photo", systemImage: "plus.circle.fill")
                }
                .padding()
                .onChange(of: pickerItem) { oldItem, newItem in
                    //guard let newItem else { return }
                    Task {
                        guard let item = pickerItem else { return }
                        try? await store.importPhoto(from: item)
                        self.pickerItem = nil
                    }
                }
            }
            .task {
                store.load()//load on appear
            }
            .navigationTitle("Memories")
        }
    }
}

#Preview {
    PictureGridView()
}

struct ThumbTile: View {
    let url: URL
    
    var body: some View {
        // disk load for now, TODO: upgrade to cache loader
        if let img = UIImage(contentsOfFile: url.path) {
            Image(uiImage: img)
                .resizable()
                .scaledToFill()
                .frame(height: 120)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(RoundedRectangle(cornerRadius: 12).stroke(.quaternary))
        } else {
            RoundedRectangle(cornerRadius: 12)
                .fill(.secondary.opacity(0.2))
                .frame(height: 120)
                .overlay {
                    Image(systemName: "photo").imageScale(.large)
                }
        }
    }
}
