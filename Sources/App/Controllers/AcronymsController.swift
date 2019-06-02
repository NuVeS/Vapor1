//
//  AcronymsController.swift
//  App
//
//  Created by Максуд on 02/06/2019.
//

import Foundation
import Vapor
import Fluent

struct AcronymController: RouteCollection {
    func boot(router: Router) throws {
        let acronymRoutes = router.grouped("api", "acronyms")
        
        acronymRoutes.get(use: getAllHandler)
        acronymRoutes.get(Acronym.parameter, use: getById)
        acronymRoutes.get("search", use: search)
        
        acronymRoutes.post(Acronym.self, use: saveHandler)
        acronymRoutes.put(use: update)
        acronymRoutes.delete(use: delete)
    }
    
    func getAllHandler(_ req: Request) -> Future<[Acronym]>{
        return Acronym.query(on: req).all()
    }
    
    func saveHandler(req: Request, acronym: Acronym) throws -> Future<Acronym>{
        return acronym.save(on: req)
    }
    
    func getById(req: Request) throws -> Future<Acronym> {
        return try req.parameters.next(Acronym.self)
    }
    
    func update(req: Request) throws -> Future<Acronym> {
        return try flatMap(to: Acronym.self, req.parameters.next(Acronym.self), req.content.decode(Acronym.self), { (old, new) in
            old.short = new.short
            old.long = new.long
            return old.save(on: req)
        })
    }
    
    func delete(req: Request) throws -> Future<HTTPStatus>{
        return try req.parameters.next(Acronym.self).delete(on: req).transform(to: HTTPStatus.ok)
    }
    
    func search(req: Request) throws -> Future<[Acronym]>{
        guard let term = req.query[String.self, at: "term"] else{
            throw Abort(.badRequest)
        }
        
        return Acronym.query(on: req).filter(\.short == term).all()
        
// IF we have multiple fields to search use "group" method
//        return Acronym.query(on: req).group(.or, closure: { or in
//            or.filter(\.short == searchTerm)
//            or.filter(\.long == searchTerm2)
//        }).sort(\.id, .ascending).all()
    }
    
    
    
}
