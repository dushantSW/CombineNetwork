# CombineNetwork

A simple light-weight network library to make network requesting simpler. It supports newer techonology such as async/await as well as traditional completion block.


# How to install
Follow the tutorial provided by Apple to install this library as a package: https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app

# How to use
Library allows to decode a structure or class while performing a network request. In order to make a network request either use ```Request``` class or extend ```RequestTask``` class for custom request.

## Decodable
In order for the client to decode an object, it should implement the protocol ```SelfDecodable``` like:
    
    struct MyCustomDecodable: SelfDecodable {
        let id: Int
        let name: String
        let age: String

        // Either use default decoder or create custom
        static var decoder: JSONDecoder = .default
    }

## Request
To perform a request you can use one of the following functions:

### Swift Combine:
``` func performRequest<Value: SelfDecodable>(_ request: RequestTask) -> AnyPublisher<Value, Error> ```

### Swift Async/Await:
``` func performRequest<Value: SelfDecodable>(_ request: RequestTask) async throws -> Value ```

### Completion block:
``` func performRequest<Value: SelfDecodable>(_ request: RequestTask, completion: @escaping ResultCompletion<Value>) ```

In each of the above function ```Value``` represents the ```Decodable``` response class.

# Example:

#### Response object: 

    struct TestDecodable: SelfDecodable {
        static var decoder: JSONDecoder = {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return decoder
        }()
        
        let  firstName: String
        let  lastName: String
    }

#### Request:

    let host = URLHost(rawValue: "myshop.com")
    let endpoint = Endpoint(path: "/items/42")
    let request = Request(host: host, endpoint: endpoint)
    let response: TestDecodable = try await NetworkClient.shared.performRequest(request)

# Suggestions

### Default URL base host:
While ```Request``` allows to change request host, scheme and other information before the call is initiated, you might wanna have a global standard host. For that extend ```URLHost```

    extension URLHost {
        static var `default`: Self {
            return URLHost(rawValue: "myshop.com")
        }
    }

    let endpoint = Endpoint(url: "/items/42")
    let request = Request(host: .default, endpoint: endpoint)

### Endpoints structure:
For better readability of endpoints, you might wanna extend the ```Endpoint``` struct to create readable paths.

    extension Endpoint {
        static func getAllItems(offset: Int, limit: Int): Self {
            return Endpoint(path: "/api/v2/items", queryParameters: [
                URLQueryItem(name: "limit", value: String(limit)),
                URLQueryItem(name: "offset", value: String(offset))
            ])
        }
    }
    let endpoint = Endpoint.getAllItems(offset: 0, limit: 20)
    let request = Request(host: .default, endpoint: endpoint)

 
