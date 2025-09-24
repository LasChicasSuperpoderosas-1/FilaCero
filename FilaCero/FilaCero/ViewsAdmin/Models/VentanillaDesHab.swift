import Foundation

// Lo que envías en el body del PUT
struct VentanillaEstadoRequest: Codable {
    let activa: Bool
}

// Lo que tu API devuelve al actualizar estado
struct VentanillaEstadoResponse: Codable, Identifiable {
    let id: Int
    let codigo: String
    let activa: Bool
    
    enum CodingKeys: String, CodingKey {
        case id     = "id_ventanilla"
        case codigo = "codigo_ventanilla"
        case activa
    }
    
    init(id: Int, codigo: String, activa: Bool) {
        self.id = id
        self.codigo = codigo
        self.activa = activa
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = try c.decode(Int.self, forKey: .id)
        codigo = try c.decode(String.self, forKey: .codigo)
        
        // aceptar true/false, 1/0 o "true"/"false"
        if let b = try? c.decode(Bool.self, forKey: .activa) {
            activa = b
        } else if let i = try? c.decode(Int.self, forKey: .activa) {
            activa = (i != 0)
        } else if let s = try? c.decode(String.self, forKey: .activa) {
            activa = (s.lowercased() == "true" || s == "1")
        } else {
            activa = false
        }
    }
}


