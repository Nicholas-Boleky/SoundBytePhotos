//
//  Memory.swift
//  SoundBytePhotos
//
//  Created by Nicholas Boleky on 8/26/25.
//

import Foundation

struct Memory: Identifiable, Hashable {
    let baseURL: URL
    var id: String { baseURL.lastPathComponent }
    
    var imageURL: URL { baseURL.appendingPathExtension("jpg") }
    var thumbURL: URL { baseURL.appendingPathExtension("thumb") }
    var audioURL: URL { baseURL.appendingPathExtension("m4a") }
    var transcriptURL: URL { baseURL.appendingPathExtension("txt") }
    
    var hasAudio: Bool { FileManager.default.fileExists(atPath: transcriptURL.path) }
    var hasTranscript: Bool { FileManager.default.fileExists(atPath: transcriptURL.path) }
}
