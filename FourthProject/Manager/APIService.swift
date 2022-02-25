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
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
              print(error)
            }
            guard let data = data else {
                print("Error: Data is corrupt.")
              return
            }
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(T.self, from: data)
                completion(decodedData)
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
