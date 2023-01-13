//
//  ReposListViewModel.swift
//  iOS Swift Graphql
//
//  Created by Damir Aushenov on 13/1/23.
//

import Foundation
import Apollo

class ReposListViewModel {
    private var currentSearchCancellable: Cancellable?
    private var currentAddStarCancellable: Cancellable?
    
    private let apollo: ApolloClient = {
            let endpointURL = URL(string: "https://api.github.com/graphql")!
            let store = ApolloStore()
            let interceptorProvider = NetworkInterceptorsProvider(
                interceptors: [TokenInterceptor(token: "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")],
                store: store
            )
            let networkTransport = RequestChainNetworkTransport(
                interceptorProvider: interceptorProvider, endpointURL: endpointURL
            )
            return ApolloClient(networkTransport: networkTransport, store: store)
        }()
    
    func search(for text: String, completion: @escaping ([RepositoryDetail]) -> Void) {
            currentSearchCancellable?.cancel()
            let query = SearchReposQuery(searchText: text)
            currentSearchCancellable = apollo.fetch(query: query, cachePolicy: .returnCacheDataAndFetch, queue: .main, resultHandler: { (result) in

                switch result {
                case .success(let data):
                    let repositoryDetails = (data.data?.search.nodes ?? [SearchReposQuery.Data.Search.Node?]()).map{$0?.asRepository}.filter{$0 != nil}.map{($0?.fragments.repositoryDetail)!}
                    completion(repositoryDetails)
                case .failure(let error):
                    print(error as Any)
                    completion([RepositoryDetail]())
                }


            })
        }
    
    func addStar(for repositoryID: String, completion: @escaping (RepositoryDetail?) -> Void ) {
        currentAddStarCancellable?.cancel()
        let mutation = AddStarMutation(repositoryId: repositoryID)
        currentAddStarCancellable = apollo.perform(mutation: mutation, queue: .main, resultHandler: { (result) in
            switch result {
            case .success(let data):
                if let data = data.data {
                    let repositoryDetails = data.addStar?.starrable?.asRepository?.fragments.repositoryDetail
                    completion(repositoryDetails)
                }
               
            case .failure(let error):
                print(error as Any)
                completion(nil)

            }
        })
    }
}
