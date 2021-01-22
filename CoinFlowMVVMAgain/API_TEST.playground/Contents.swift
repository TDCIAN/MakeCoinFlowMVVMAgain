import UIKit

let urlSession = URLSession.shared

let newsURL = URL(string: "http://coinbelly.com/api/get_rss")!

let dataTask = urlSession.dataTask(with: newsURL) { (data, response, error) in
        
}

