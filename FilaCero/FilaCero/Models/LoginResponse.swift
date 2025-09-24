//
//  LoginResponse.swift
//  FilaCero
//
//  Created by Alumno on 23/09/25.
//

import Foundation

struct LoginResponse: Decodable {
    let ok: Bool
    let user_id: Int?
    let rol: String?
    let msg: String?

}
