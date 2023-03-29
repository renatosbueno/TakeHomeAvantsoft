//
//  Networker.swift
//
//

import Foundation

enum HttpMethod: String, CaseIterable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

protocol NetworkerProtocol: AnyObject {
    func request<DataType: Codable>(endpoint: NetworkEndpoint, type: DataType.Type, completion: @escaping (Result<DataType?, NetworkErrorType>) -> Void)
    func requestData(endpoint: NetworkEndpoint, completion: @escaping (Result<Data, NetworkErrorType>) -> Void)
}

final class Networker: NSObject, NetworkerProtocol {
    
    private var task: URLSessionDataTask?
    
    func request<DataType: Codable>(endpoint: NetworkEndpoint, type: DataType.Type, completion: @escaping (Result<DataType?, NetworkErrorType>) -> Void) {
        guard let urlRequest = setupUrlRequest(endpoint: endpoint) else {
            completion(.failure(.error(code: .unkown)))
            return
        }
        task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let urlResponse = response as? HTTPURLResponse, error != nil {
                let error = self.handleErrorResponse(response: urlResponse)
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(.error(code: .decodingError)))
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            let object = try? decoder.decode(DataType.self, from: data)
            completion(.success(object))
        }
        task?.resume()
    }
    
    func requestData(endpoint: NetworkEndpoint, completion: @escaping (Result<Data, NetworkErrorType>) -> Void) {
        guard let urlRequest = setupUrlRequest(endpoint: endpoint) else {
            completion(.failure(.error(code: .unkown)))
            return
        }
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
        task = session.dataTask(with: urlRequest) { data, response, error in
            if let urlResponse = response as? HTTPURLResponse, error != nil {
                let error = self.handleErrorResponse(response: urlResponse)
                completion(.failure(error))
                return
            }
            guard let data = data else {
                completion(.failure(.error(code: .decodingError)))
                return
            }
            completion(.success(data))
        }
        task?.resume()
    }
    
    private func handleErrorResponse(response: HTTPURLResponse) -> NetworkErrorType {
        let errorType = NetworkErrorStatusCode(rawValue: response.statusCode)
        let error: NetworkErrorType = {
            guard let errorCode = errorType else {
                return .other(statusCode: response.statusCode)
            }
            return .error(code: errorCode)
        }()
        return error
    }
    
    private func decodeObject<T: Codable>(data: Data, type: Codable) -> T? {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try? decoder.decode(T.self, from: data)
    }
    
    
    private func setupUrlRequest(endpoint: NetworkEndpoint) -> URLRequest? {
        guard let url = URL(string: endpoint.baseUrl + endpoint.path) else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.allHTTPHeaderFields = endpoint.headers
        
        return urlRequest
    }
}
extension Networker: URLSessionDelegate {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        let urlCredential = URLCredential(trust: challenge.protectionSpace.serverTrust!)
        completionHandler(.useCredential, urlCredential)
    }
    
}
