import UIKit

let urlSession = URLSession.shared

let newsURL = URL(string: "http://coinbelly.com/api/get_rss")!

let dataTask = urlSession.dataTask(with: newsURL) { (data, response, error) in
    let successRange = 200..<300
    guard error == nil,
          let statusCode = (response as? HTTPURLResponse)?.statusCode,
          successRange.contains(statusCode) else {
        return
    }
    guard let responseData = data else { return }
    let string = String(data: responseData, encoding: .utf8)
    print(string)
}
dataTask.resume()
