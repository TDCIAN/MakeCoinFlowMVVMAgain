import UIKit

let xAxis = ["mon", "tue", "wed", "thu"]
let yAxis = [4, 6, 8, 10]

//let tuples: [(key: String, value: Int)]


let zipped = zip(xAxis, yAxis)
let tuples = zipped.map({(key: $0, value: $1)})
print(tuples)
