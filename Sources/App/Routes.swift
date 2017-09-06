import Vapor

extension Droplet {
    func setupRoutes() throws {
        get("hello") { req in
            
            let digest = try self.hash.make("world")
            
            var json = JSON()
            try json.set("hello", digest)
            return json
        }

        get("plaintext") { req in
            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)
    }
}
