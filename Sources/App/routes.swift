import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    router.get("home") { (req) -> String in
        return "Whatsup, dude?"
    }
    
    router.post("api", "acronyms") { (req) -> Future<Acronym> in
        return try req.content.decode(Acronym.self).flatMap(to: Acronym.self, { (acronym)  in
            return acronym.save(on: req)
        })
    }
}

struct InfoData: Content{
    let name: String
}

struct InfoResponse: Content {
    let response: InfoData
}
