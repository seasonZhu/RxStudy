import UIKit

struct Token: Codable {
    @JSONString
    var body: Body?
}

struct Body: Codable {
    let timestamp: String?
}

let badJSONString = """
{
    "body":"{\"timestamp\":\"2021-10-02 03:56:46\"}"
}
"""
@propertyWrapper
struct JSONString<Base: Codable>: Codable {
    var wrappedValue: Base
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self),
           let data = string.data(using: .utf8) {
            self.wrappedValue = try JSONDecoder().decode(Base.self, from: data)
            return
        }
        
        self.wrappedValue = try container.decode(Base.self)
    }
        
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let data = try JSONEncoder().encode(wrappedValue)
        if let string = String(data: data, encoding: .utf8) {
            try container.encode(string)
        }
    }
}

let jsonStringData = badJSONString.data(using: .utf8)!

let model = try? JSONDecoder().decode(Token.self, from: jsonStringData)

print(model)


struct MixinIntModel: Codable {
    @MixinType
    var result: Int?
}

let IntJSONString = """
{
    "result": 1
}
"""

let intData = IntJSONString.data(using: .utf8)!

let intModel = try? JSONDecoder().decode(MixinIntModel.self, from: intData)

print(intModel?.result)


struct MixinStringModel: Codable {
    @MixinType
    var result: String?
}

let StringJSONString = """
{
    "result": "1"
}
"""
let stringData = StringJSONString.data(using: .utf8)!

let stringModel = try? JSONDecoder().decode(MixinStringModel.self, from: stringData)

print(stringModel?.result)

struct MixinBoolModel: Codable {
    @MixinType
    var result: Bool?
}

struct MixinSomeModel: Codable {
    @Default
    var result: Bool
}

let BoolJSONString = """
{
    "result": true
}
"""
let boolData = BoolJSONString.data(using: .utf8)!

let boolModel = try? JSONDecoder().decode(MixinBoolModel.self, from: boolData)

print(boolModel?.result)
