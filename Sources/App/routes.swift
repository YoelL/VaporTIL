import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Basic "Hello, world!" example
    router.get("hello") { req in
        return "Hello, world!"
    }

	
//	Create - POST Request
	router.post("api", "acronyms") { req -> Future<Acronym> in
	
		return try req.content.decode(Acronym.self)
			.flatMap(to: Acronym.self) { acronym in
	
				return acronym.save(on: req)
		}
	}
	
	
//	Retrive All - GET
	router.get("api", "acronyms") { req -> Future<[Acronym]> in
		return Acronym.query(on: req).all()
	}
	
	
//	Retrive Single - GET
	router.get("api", "acronyms", Acronym.parameter) {
		req -> Future<Acronym> in
		// 2
		return try req.parameters.next(Acronym.self)
	}
	
//	Update Single Acronym
	router.put("api", "acronyms", Acronym.parameter) {
		req -> Future<Acronym> in
	
		return try flatMap(to: Acronym.self,
						   req.parameters.next(Acronym.self),
						   req.content.decode(Acronym.self)) {
							acronym, updatedAcronym in
							// 3
							acronym.short = updatedAcronym.short
							acronym.long = updatedAcronym.long
							// 4
							return acronym.save(on: req)
		}
	}
	
//	Delete Single Acronym
	router.delete("api", "acronyms", Acronym.parameter) {
		req -> Future<HTTPStatus> in
		// 2
		return try req.parameters.next(Acronym.self)
		// 3
		.delete(on: req)
		// 4
		.transform(to: HTTPStatus.noContent)
	}
	
}
