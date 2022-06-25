//
//  DataFetcherService.swift

import Foundation

class DataFetcherService {

	var networkDataFetcher: DataFetcher

	init(networkDataFetcher: DataFetcher = NetworkDataFetcher()) {
		self.networkDataFetcher = networkDataFetcher
	}

	func fetchATMs(completion: @escaping((Result<ATMResponse, CustomError>) -> Void)) {
		let urlATMsString = Constants.share.urlATMsString
		networkDataFetcher.fetchGenericJSONData(urlString: urlATMsString, response: completion)
	}

	func fetchBranches(completion:  @escaping((Result<Branch, CustomError>) -> Void)) {
		let urlbBranchesString = Constants.share.urlbBranchesString
		networkDataFetcher.fetchGenericJSONData(urlString: urlbBranchesString, response: completion)
	}

	func fetchInfoboxes(completion:  @escaping((Result<[InfoBoxElement], CustomError>) -> Void)) {
		let urlInfoboxString = Constants.share.urlInfoboxString
		networkDataFetcher.fetchGenericJSONData(urlString: urlInfoboxString, response: completion)
	}
}
