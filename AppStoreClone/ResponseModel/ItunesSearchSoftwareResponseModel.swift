//
//  ItunesSearchSoftwareResponseModel.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/19.
//

import Foundation

struct ItunesSearchSoftwareResponseModel {
    let results: [Item]
}

extension ItunesSearchSoftwareResponseModel: Decodable {
    enum CodingKeys: String, CodingKey {
        case results
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.results = (try? container.decode([Item].self, forKey: .results)) ?? []
    }
}

extension ItunesSearchSoftwareResponseModel {
    struct Item {
        let trackCensoredName: String
        let screenshotUrls: [String]
        let artworkUrl60: String
        let artworkUrl512: String
        let artworkUrl100: String
        let genres: [String]
        let description: String
        let artistName: String
        let releaseNotes: String
        let userRatingCount: Int
        let averageUserRating: Double
        let trackContentRating: String
        let languageCodesISO2A: [String]
        let version: String
        let releaseDate: String
        let currentVersionReleaseDate: String
    }
}

extension ItunesSearchSoftwareResponseModel.Item: Decodable {
    enum CodingKeys: String, CodingKey {
        case trackCensoredName
        case screenshotUrls
        case artworkUrl60
        case artworkUrl512
        case artworkUrl100
        case genres
        case description
        case artistName
        case releaseNotes
        case userRatingCount
        case averageUserRating
        case trackContentRating
        case languageCodesISO2A
        case version
        case releaseDate
        case currentVersionReleaseDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.trackCensoredName = (try? container.decode(String.self, forKey: .trackCensoredName)) ?? ""
        self.screenshotUrls = (try? container.decodeIfPresent([String].self, forKey: .screenshotUrls)) ?? []
        self.artworkUrl60 = (try? container.decode(String.self, forKey: .artworkUrl60)) ?? ""
        self.artworkUrl512 = (try? container.decode(String.self, forKey: .artworkUrl512)) ?? ""
        self.artworkUrl100 = (try? container.decode(String.self, forKey: .artworkUrl100)) ?? ""
        self.genres = (try? container.decode([String].self, forKey: .genres)) ?? []
        self.description = (try? container.decode(String.self, forKey: .description)) ?? ""
        self.artistName = (try? container.decode(String.self, forKey: .artistName)) ?? ""
        self.releaseNotes = (try? container.decode(String.self, forKey: .releaseNotes)) ?? ""
        self.userRatingCount = (try? container.decode(Int.self, forKey: .userRatingCount)) ?? 0
        self.averageUserRating = (try? container.decode(Double.self, forKey: .averageUserRating)) ?? 0
        self.trackContentRating = (try? container.decode(String.self, forKey: .trackContentRating)) ?? ""
        self.languageCodesISO2A = (try? container.decode([String].self, forKey: .languageCodesISO2A)) ?? []
        self.version = (try? container.decode(String.self, forKey: .version)) ?? ""
        self.releaseDate = (try? container.decode(String.self, forKey: .releaseDate)) ?? ""
        self.currentVersionReleaseDate = (try? container.decode(String.self, forKey: .currentVersionReleaseDate)) ?? ""
    }
}
