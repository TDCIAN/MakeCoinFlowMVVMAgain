import UIKit
import Alamofire
import SwiftyJSON

let urlSession = URLSession.shared

//{
//    "title": "True Life: I’m a Bitcoin",
//    "link": "https://www.coindesk.com/true-life-im-a-bitcoin",
//    "date": "Mon, 01 Apr 2019 16:15:16 +0000",
//    "timestamp": 1554135316,
//    "description": "What's it like to be bitcoin? It's not all it's hashed out to be.",
//    "imageUrl": "http://coinbelly.com/api/images/3rdparty/coindesk.com_0.jpg"
//},

struct NewsResponse: Codable {
    let articleArray: [Article]
}

struct Article: Codable {
    let title: String
    let link: String
    let date: String
    let timestamp: TimeInterval
    let description: String
    let imageURL: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case link
        case date
        case timestamp
        case description
        case imageURL = "imageUrl"
    }
}

//let taskWithNewsURL = urlSession.dataTask(with: newsURL) { (data, response, error) in
//    let successRange = 200..<300
//    guard error == nil,
//          let statusCode = (response as? HTTPURLResponse)?.statusCode,
//          successRange.contains(statusCode) else {
//        return
//    }
//    guard let responseData = data else { return }
//    let string = String(data: responseData, encoding: .utf8)
////    print(string)
//    let decoder = JSONDecoder()
//    do {
//        let response = try decoder.decode([NewsResponse].self, from: responseData)
//        print("리스폰스 --> :\(response.first)")
//    } catch {
//        print("--> error: \(error.localizedDescription)")
//    }
//}
//taskWithNewsURL.resume()
//let newsURL = URL(string: "http://coinbelly.com/api/get_rss")!
//AF.request(newsURL)
//    .responseJSON { (responseData) in
//        switch responseData.result {
//        case .success(let successedResult):
////            print("결과물: \(successedResult)")
//            let json = JSON(successedResult)
//            let decoder = JSONDecoder()
//            do {
//                let data = try JSONSerialization.data(withJSONObject: successedResult, options: .prettyPrinted)
////                let data = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
//                let response = try decoder.decode([NewsResponse].self, from: data)
//
//                print("뉴스 리스폰스: \(response)")
//            } catch {
//
//            }
//        case .failure(let error):
//            print("뉴스 에러 --> :\(error.localizedDescription)")
//        }
//}

struct CoinListResponse: Codable {
    let raw: RawData
    
    enum CodingKeys: String, CodingKey {
        case raw = "RAW"
    }
}
//"https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC,ETH,DASH,LTC,ETC,XRP,BCH,XMR,QTUM,ZEC,BTG&tsyms=USD")!
struct RawData: Codable {
//    let btc: Coin
//    let eth: Coin
//    let dash: Coin
    let ltc: Coin
    let etc: Coin
    let xrp: Coin
//    let bch: Coin
//    let xmr: Coin
//    let qtum: Coin
//    let zec: Coin
//    let btg: Coin
    
    enum CodingKeys: String, CodingKey {
//        case btc = "BTC"
//        case eth = "ETH"
//        case dash = "DASH"
        case ltc = "LTC"
        case etc = "ETC"
        case xrp = "XRP"
//        case bch = "BCH"
//        case xmr = "XMR"
//        case qtum = "QTUM"
//        case zec = "ZEC"
//        case btg = "BTG"
    }
}

struct Coin: Codable {
    let usd: CurrencyInfo
    
    enum CodingKeys: String, CodingKey {
        case usd = "USD"
    }
}

struct CurrencyInfo: Codable {
    let price: Double
    let changeLast24H: Double
    let changePercentLast24H: Double
    let market: String
    
    enum CodingKeys: String, CodingKey {
        case price = "PRICE"
        case changeLast24H = "CHANGE24HOUR"
        case changePercentLast24H = "CHANGEPCT24HOUR"
        case market = "LASTMARKET"
    }
}

//"LASTMARKET": "Coinbase",
//"VOLUMEHOUR": 426.5735325400038,
//"VOLUMEHOURTO": 14310564.979030505,
//"OPENHOUR": 32802.28,
//"HIGHHOUR": 32897.76,
//"LOWHOUR": 32641.85,
//"TOPTIERVOLUME24HOUR": 35854.907198400004,
//"TOPTIERVOLUME24HOURTO": 1154980952.6058037,
//"CHANGE24HOUR": 166.63000000000102,
//"CHANGEPCT24HOUR": 0.5127485544232633,

let coinListURL = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC,ETH,DASH,LTC,ETC,XRP,BCH,XMR,QTUM,ZEC,BTG&tsyms=USD")!
AF.request(coinListURL)
    .responseJSON { (responseData) in
        switch responseData.result {
        case .success(let succesedResult):
            let decoder = JSONDecoder()
            do {
//                print("석세스드리절트: \(succesedResult)")
                let coinListData = try JSONSerialization.data(withJSONObject: succesedResult, options: .prettyPrinted)
//                print("코인리스트 데이터 --> \(coinListData)")
//                let string = String(data: coinListData, encoding: .utf8)
//                print("스트링: \(string)")
//                let json = JSON(string)
//                print("제이슨: \(json)")
                let response = try decoder.decode(CoinListResponse.self, from: coinListData)
                print("코인리스트 리스폰스 --> :\(response.raw)")
            } catch {
                print("에러: \(error.localizedDescription)")
            }
        case .failure(let error):
            print("코인리스트 에러 --> :\(error.localizedDescription)")
        }
}

//struct ChartDataResponse: Codable {
//    let chartDatas: [ChartData]
//
//    enum CodingKeys: String, CodingKey {
//        case chartDatas = "Data"
//    }
//}
//
//struct ChartData: Codable {
//    let time: TimeInterval
//    let closePrice: Double
//
//    enum CodingKeys: String, CodingKey {
//        case time
//        case closePrice = "close"
//    }
//}
//
//let coinChartURL = URL(string: "https://min-api.cryptocompare.com/data/histohour?fsym=BTC&tsym=USD&limit=24")!
//AF.request(coinChartURL)
//    .responseJSON { (responseData) in
//        switch responseData.result {
//        case .success(let successedResult):
////            print("석세스드리절트: \(successedResult)")
//            let decoder = JSONDecoder()
//            do {
//                let resultData = try JSONSerialization.data(withJSONObject: successedResult, options: .prettyPrinted)
////                print("리절트데이터: \(resultData)")
//                let response = try decoder.decode(ChartDataResponse.self, from: resultData)
//                print("리스폰스: \(response)")
//            } catch {
//
//            }
//        case .failure(let error):
//            print("코인차트 에러 --> :\(error.localizedDescription)")
//        }
//}
