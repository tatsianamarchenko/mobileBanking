//
//  NetworkDataFetcher.swift

import Foundation

protocol DataFetcher {
    func fetchGenericJSONData<T: Decodable>(urlString: String, response: @escaping((Result<T, CustomError>) -> Void))
}

class NetworkDataFetcher: DataFetcher {

    var networking: Networking
    
    init(networking: Networking = NetworkService()) {
        self.networking = networking
    }

    func fetchGenericJSONData<T: Decodable>(urlString: String, response: @escaping((Result<T, CustomError>) -> Void)) {
        networking.request(urlString: urlString) { (data, error) in
            if let error = error {
                print("Error received requesting data: \(error.localizedDescription)")
				response(.failure(.errorGeneral))
            }

			guard let decoded = self.decodeJSON(type: T.self, from: data) else {
				response(.failure(.corruptedData))
				return
			}
			response(.success(decoded))

        }
    }

    func decodeJSON<T: Decodable>(type: T.Type, from: Data?) -> T? {
        let decoder = JSONDecoder()
        guard let data = from else { return nil }
        do {
            let objects = try decoder.decode(type.self, from: data)
            return objects
        } catch let jsonError {
            print("Failed to decode JSON", jsonError)
            return nil
        }
    }
}

enum CustomError: Error {
  case corruptedData
  case errorGeneral
}
