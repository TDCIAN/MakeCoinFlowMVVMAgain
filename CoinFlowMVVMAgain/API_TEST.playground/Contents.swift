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

let newsURL = URL(string: "http://coinbelly.com/api/get_rss")!

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

AF.request(newsURL)
    .responseJSON { (responseData) in
        switch responseData.result {
        case .success(let successedResult):
//            print("결과물: \(successedResult)")
            let json = JSON(successedResult)
            let jsonEncoder = JSONEncoder()
            if let result = successedResult as! Data {
                let jsonData = try? jsonEncoder.encode(result)
                if let jsonData = jsonData, let jsonString = String(data: jsonData, encoding: .utf8) {
                    print("제이슨스트링: \(jsonString)")
                }
            } else {
                print("석세스드리절트: \(successedResult)")
            }
            
//            print("제이슨: \(json)")
        case .failure(let error):
            print("실패임: \(error.localizedDescription)")
        }
}
