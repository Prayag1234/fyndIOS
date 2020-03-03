
import Foundation

struct ProductsList: Codable {
    var products: [Product]?
    let name: String?
}

struct Product: Codable {
    let sku: Int
    let name: String
    let cost: Int
    var imageURL: URL? {
        if let url = URL(string: "https://i.picsum.photos/id/\(Int.random(in: 100...999))/200/200.jpg"){
            return url
        }
        return nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case sku
        case name
        case cost
    }
}
