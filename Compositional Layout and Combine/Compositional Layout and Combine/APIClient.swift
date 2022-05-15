//
//  APIClient.swift
//  Compositional Layout and Combine
//
//  Created by Olexsii Levchenko on 5/15/22.
//

import Foundation
import Combine


class APIClient {
    
    public func searchPhotos(for query: String) -> AnyPublisher<[Hits], Error> {
        let perPage = 200
        let query = query.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "paris"
        let endPoint = "https://pixabay.com/api/?key=\(Config.apikey)&q=\(query)&per_page=\(perPage)&safesearch=true"
        
        guard let url = URL(string: endPoint) else {
        fatalError("Could not return photo")
        }
        
        //using Combine for networking
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data) //data
            .decode(type: Photo.self, decoder: JSONDecoder())
            .map { photo in
                photo.hits
            }
            .receive(on: DispatchQueue.main) //on the main thread
            .eraseToAnyPublisher()
    }
}
