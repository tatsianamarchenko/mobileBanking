import Foundation

public class APIService {

  func getJSON<T: Decodable> (urlString: String,
							  runQueue: DispatchQueue,
							  complitionQueue: DispatchQueue,
							  completion: @escaping((Result<T, CustomError>) -> Void)) {
	runQueue.async {
	  guard let url = URL(string: urlString) else {
		print("Error: Invalid URL.")
		return
	  }

	  let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 100)
	  URLSession.shared.dataTask(with: request) { (data, _, error) in
		if let error = error {
		  completion(.failure(.errorGeneral))
		  return
		}
		guard let data = data else {
		  completion(.failure(.corruptedData))
		  return
		}
		let decoder = JSONDecoder()
		do {
		  let decodedData = try decoder.decode(T.self, from: data)
		  complitionQueue.async {
			completion(.success(decodedData))
		  }
		} catch {
		  print("Error: \(error.localizedDescription)")
		}
	  }.resume()
	}
  }
}
enum CustomError: Error {
  case corruptedData
  case errorGeneral
}
