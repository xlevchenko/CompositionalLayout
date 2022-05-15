//
//  Photo.swift
//  Compositional Layout and Combine
//
//  Created by Olexsii Levchenko on 5/15/22.
//

import Foundation

struct Photo: Decodable {
    let hits: [Hits]
}

struct Hits: Decodable, Hashable {
    let id: Int
    let webformatURL: String
}
