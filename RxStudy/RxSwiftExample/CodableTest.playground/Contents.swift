import UIKit

struct MixinIntModel: Codable {
    @MixinType
    var result: Int?
}

let IntJSONString = """
{
    "result": 1
}
"""

//let intData = IntJSONString.data(using: .utf8)!
//
//let intModel = try? JSONDecoder().decode(MixinIntModel.self, from: intData)
//
//print(intModel?.result)


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


let StringValueJSONString = """
{
    "result": 3.1415926
}
"""

struct StringValueModel: Codable {
    @StringValue
    var result: String?
}

let StringValueData = StringValueJSONString.data(using: .utf8)!

let stringValueModel = try? JSONDecoder().decode(StringValueModel.self, from: StringValueData)

print(stringValueModel?.result)

print(stringValueModel?.$result.boolToIntStringValue)

//let someData = try JSONEncoder().encode(stringValueModel!)
//
//let any = try JSONSerialization.jsonObject(with: someData)
//
//let someString = String(data: someData, encoding: .utf8)
//
//print(someData)
//
//print(any)
//
//print(someString)

/// 这种"""字符串"""JSONString没法解析出来,必须要使用#""#这种方式,或者从.json文件读取才能正常解析
let badJSONString = #"{"result": true,"body": "{\"ret_code\":\"0\",\"ret_msg\":\"成功\",\"serial_number\":\"20211002115646portal511788\",\"timestamp\":\"2021-10-02 03:56:46\",\"response_data\":{\"token\":\"0765499c-8643-4491-8c8e-50f92a2ea004\",\"expiredMills\":1633751806616}}"}"#

// MARK: - Token
struct Token: Codable {
    let result: Bool?

    @JSONString
    var body: Body?
}

// MARK: - Body
struct Body: Codable {

    let retCode: String?
    let retMsg: String?
    let serialNumber: String?
    let timestamp: String?

    @JSONString
    var responseData: ResponseData?

    enum CodingKeys: String, CodingKey {
        case retCode = "ret_code"
        case retMsg = "ret_msg"
        case serialNumber = "serial_number"
        case timestamp = "timestamp"
        case responseData = "response_data"
    }
}

// MARK: - ResponseData
struct ResponseData: Codable {
    let token: String?
    let expiredMills: Date?
}

let jsonStringData = badJSONString.data(using: .utf8)!//try! Data(contentsOf: URL(fileURLWithPath: Bundle.main.path(forResource: "ToCodable", ofType: "json")!))

let jsonStringModel = try? JSONDecoder().decode(Token.self, from: jsonStringData)

print(jsonStringModel)

let someData = try JSONEncoder().encode(jsonStringModel!)

let any = try JSONSerialization.jsonObject(with: someData)

let someString = String(data: someData, encoding: .utf8)

print(someData)

print(any)

print(someString)


let formatter = NumberFormatter()
formatter.numberStyle = .decimal
formatter.maximumFractionDigits = 1

let numbers = [1.2, 1.22, 1.25, 1.27, -1.25, 0.03]
let modes: [NumberFormatter.RoundingMode] = [.halfUp]
    //[.ceiling, .floor, .up, .down, .halfUp, .halfDown, .halfEven]

for mode in modes {
    formatter.roundingMode = mode

    for number in numbers {
        let some = formatter.string(for: number)
        print(some!)
    }
}

/// 使用Decimal类型来接住整型与浮点型
let πJSONSring = """
{
    "result": 3.1415926,
    "data": 1
}
"""

struct DecimalModel: Codable {
    var result: Decimal?
    var data: Decimal?
}

let πData = πJSONSring.data(using: .utf8)!

let πModel = try? JSONDecoder().decode(DecimalModel.self, from: πData)

print(πModel)

print(πModel?.result?.formatted())

print(πModel?.data?.formatted())

typealias ErrorStringConvertible = Error & CustomDebugStringConvertible & CustomStringConvertible

struct SexModel: Codable {
    @GuardEnumType
    var sexType: SexType
}


let SexTypeJSONString = """
{
    "sexType": "4"
}
"""

let sexData = SexTypeJSONString.data(using: .utf8)!

let sexModel = try? JSONDecoder().decode(SexModel.self, from: sexData)

print(sexModel?.sexType)

let sexModelData = JSONEncoder().encode(sexModel!)

let sexModelJson = try JSONSerialization.jsonObject(with: sexModelData)

print(sexModelJson)


