import Vapor
import Fluent

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let acronymsController = AcronymController()
    try router.register(collection: acronymsController)
    
    router.get("home") { (req) -> String in
        return "Whatsup, dude?"
    }    
}

struct InfoData: Content{
    let name: String
}

struct InfoResponse: Content {
    let response: InfoData
}
