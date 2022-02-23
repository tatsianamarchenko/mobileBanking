import Foundation

public class APIService {
    public let urlString: String
    public init(urlString: String) {
        self.urlString = urlString
    }

    public func getJSON<T: Decodable>(completion: @escaping (T) -> Void) {
        guard let url = URL(string: urlString) else {
            fatalError("Error: Invalid URL.")
        }
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                fatalError("Error: \(error.localizedDescription)")
            }
            guard let data = data else {
                fatalError("Error: Data is corrupt.")
            }
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                completion(decodedData)
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
