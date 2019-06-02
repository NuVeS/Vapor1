import Vapor
import Fluent

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
    
    router.get("api", "acronyms") { (req) -> Future<[Acronym]> in
        return Acronym.query(on: req).all()
    }
    router.get("api", "acronyms", Acronym.parameter) { (req) -> Future<Acronym> in
        return try req.parameters.next(Acronym.self)
    }
    
    router.put("api", "acronyms", Acronym.parameter) { (req) -> Future<Acronym> in
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self), { (acronym, updateAcronym) in
            acronym.short = updateAcronym.short
            acronym.long = updateAcronym.long
            
            return acronym.save(on: req)
        })
    }
    
    router.delete("api", "acronyms", Acronym.parameter) { (req) -> Future<HTTPStatus> in
        return try req.parameters.next(Acronym.self)
                .delete(on: req)
                .transform(to: HTTPStatus.ok)
    }
    
    router.get("api", "acronyms", "search") { (req) -> Future<[Acronym]> in
        guard let searchTerm = req.query[String.self, at: "term"] else{
            throw Abort(.badRequest)
        }
        
        return Acronym.query(on: req).filter(\.short == searchTerm).sort(\.id).all()
        
        // IF we have multiple fields to search use "group" method
//        return Acronym.query(on: req).group(.or, closure: { or in
//            or.filter(\.short == searchTerm)
//            or.filter(\.long == searchTerm)
//        }).sort(\.id, .ascending).all()
    }
    
    router.get("api", "acronyms", "first") {
        req -> Future<Acronym> in
        // 2
        return Acronym.query(on: req)
            // 3
            .first()
            .map(to: Acronym.self) { acronym in
                guard let acronym = acronym else {
                    throw Abort(.notFound)
                }
                // 4
                return acronym
        }
    }
    
}

struct InfoData: Content{
    let name: String
}

struct InfoResponse: Content {
    let response: InfoData
}
