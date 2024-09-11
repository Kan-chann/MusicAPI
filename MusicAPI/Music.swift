//
//  Music.swift
//  MusicAPI
//
//  Created by Kanno Taichi on 2024/09/02.
//

import Foundation

struct MusicResponce: Codable{
    var results:[Music]
}

struct Music: Codable{
    var trackName : String
    var artworkUrl60: URL
}
