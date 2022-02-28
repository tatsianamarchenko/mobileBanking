import Foundation

public class APIService {
    public let urlString: String
    public init(urlString: String) {
        self.urlString = urlString
    }
     func getJSON(completion: @escaping (Result<ATMResponse, CustomError>) -> Void) {
        guard let url = URL(string: urlString) else {
            print("Error: Invalid URL.")
          return
        }

       let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 13)
        URLSession.shared.dataTask(with: request) { (data, _, error) in
            if let error = error {
              print(error)
              completion(.failure(CustomError.errorGeneral))
              return
            }
            guard let data = data else {
                print("Error: Data is corrupt.")
              completion(.failure(CustomError.corruptedData))
              return
            }
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(ATMResponse.self, from: data)
              completion(.success(decodedData))
            } catch {
                print("Error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
enum CustomError: Error {
  case corruptedData
  case errorGeneral
}
