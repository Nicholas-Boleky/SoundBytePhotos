//
//  File.swift
//  SoundBytePhotos
//
//  Created by Nicholas Boleky on 8/27/25.
//

import SwiftUI
import PhotosUI
import UIKit

@MainActor
final class MemoryStore: ObservableObject {
    @Published private(set) var memories: [Memory] = []

    private let fm = FileManager.default
    private var docs: URL {
        fm.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func load() {
        // List files in Documents, keep only ".thumb", strip extension → base
        let files = (try? fm.contentsOfDirectory(at: docs, includingPropertiesForKeys: nil)) ?? []
        let bases = files
            .filter { $0.pathExtension == "thumb" }
            .map { $0.deletingPathExtension() }

        memories = bases
            .map { Memory(baseURL: $0) }
            .sorted { $0.id > $1.id } // newest first if you like
    }

    /// Import from PhotosPicker (no Photos permission required).
    func importPhoto(from item: PhotosPickerItem) async throws {
        // Pull bytes from the picker (downloads from iCloud if needed)
        guard let data = try await item.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else {
            throw ImportError.badImage
        }

        // normalize orientation before saving
        let image = normalizeOrientation(uiImage)
        try await save(uiImage: image)
    }
    
    private func normalizeOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
    }

    /// For programmatic reads after explicit Photos permission,
    /// call this with a UIImage obtained.
    func save(uiImage: UIImage) async throws {
        let baseName = UUID().uuidString
        let base = docs.appendingPathComponent(baseName)

        // Full-size JPG
        guard let jpg = uiImage.jpegData(compressionQuality: 0.9) else { throw ImportError.badImage }
        try jpg.write(to: base.appendingPathExtension("jpg"), options: .atomic)

        // Thumbnail (about 600px on the long edge)
        let thumbImage = await uiImage.byPreparingThumbnail(ofSize: CGSize(width: 600, height: 600)) ?? uiImage
        if let thumbData = thumbImage.jpegData(compressionQuality: 0.7) {
            try thumbData.write(to: base.appendingPathExtension("thumb"), options: .atomic)
        }

        load() // publish changes for SwiftUI
    }

    enum ImportError: Error { case badImage }
}
