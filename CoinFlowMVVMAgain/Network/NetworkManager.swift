//
//  NetworkManager.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/26.
//

import Foundation
import Alamofire

class NetworkManager {
    
    static let session = URLSession.shared
    
}

//extension NetworkManager {
//    static func requestCoinList(completion: @escaping (Result<[Coin], Error>) -> Void) {
//        let param:RequestParam = .url(["fsyms":"BTC,ETH,DASH,LTC,ETC,XRP,BCH,XMR,QTUM,ZEC,BTG","tsyms":"USD"])
//        guard let coinListURL = CoinListRequest(param: param).urlRequest()?.url else { return }
////        let coinListURL = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC,ETH,DASH,LTC,ETC,XRP,BCH,XMR,QTUM,ZEC,BTG&tsyms=USD")!
//        let taskWithCoinListURL = session.dataTask(with: coinListURL) { (data, response, error) in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            guard let responseData = data else{ return }
//            let decoder = JSONDecoder()
//            do {
//                let response = try decoder.decode(CoinListResponse.self, from: responseData)
//                print("--> success: \(response.raw.btg)")
//                let coinList = response.raw.allCoins()
//                completion(.success(coinList))
//            } catch let error {
//                print("--> coin list error: \(error.localizedDescription)")
//                completion(.failure(error))
//            }
//        }
//        taskWithCoinListURL.resume()
//    }
//
//    static func requestCoinChartData(completion: @escaping (Result<[ChartData], Error>) -> Void) {
//        let param:RequestParam = .url(["fsym":"BTC", "tsym":"USD", "limit":"24"])
//        guard let coinChartDataURL = CoinChartDataRequest(period: .day, param: param).urlRequest()?.url else { return }
////        let coinChartDataURL = URL(string: "https://min-api.cryptocompare.com/data/histohour?fsym=BTC&tsym=USD&limit=24")!
//        let taskWithCoinChartDataURL = session.dataTask(with: coinChartDataURL) { (data, response, error) in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            guard let responseData = data else { return }
//            let decoder = JSONDecoder()
//            do {
//                let response = try decoder.decode(ChartDataResponse.self, from: responseData)
//                let chartDatas = response.chartDatas
//                completion(.success(chartDatas))
//            } catch let error {
//                print("--> coin chart error: \(error.localizedDescription)")
//                completion(.failure(error))
//            }
//        }
//        taskWithCoinChartDataURL.resume()
//    }
//
//    static func requestNewsList(completion: @escaping (Result<[Article], Error>) -> Void) {
////        let newsURL = URL(string: "http://coinbelly.com/api/get_rss")!
//        guard let newsURL = NewsListRequest().urlRequest()?.url else{ return }
//        let taskWithNewsURL = session.dataTask(with: newsURL) { (data, response, error) in
//            if let error = error {
//                completion(.failure(error))
//                return
//            }
//            guard let responseData = data else { return }
//            let decoder = JSONDecoder()
//            do {
//                let response = try decoder.decode([NewsResponse].self, from: responseData)
//                let articles = response.flatMap { $0.articleArray }
//                completion(.success(articles))
//            } catch let error {
//                print("--> news list error: \(error.localizedDescription)")
//                completion(.failure(error))
//            }
//        }
//        taskWithNewsURL.resume()
//    }
//}

extension NetworkManager {
    static func requestCoinList(completion: @escaping (Result<[Coin], Error>) -> Void) {
        let param:RequestParam = .url(["fsyms":"BTC,ETH,DASH,LTC,ETC,XRP,BCH,XMR,QTUM,ZEC,BTG","tsyms":"USD"])
        guard let coinListURL = CoinListRequest(param: param).urlRequest()?.url else { return }
        AF.request(coinListURL).responseJSON { response in
            switch response.result {
            case .success(let successData):
                let decoder = JSONDecoder()
                do {
                    let coinListRawData = try JSONSerialization.data(withJSONObject: successData, options: .prettyPrinted)
                    let coinListProcessedData = try decoder.decode(CoinListResponse.self, from: coinListRawData)
                    completion(.success(coinListProcessedData.raw.allCoins()))
                } catch let error {
                    print("==> coin list decoding error: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("==> coin list error: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
    }
    
    static func requestCoinChartData(coinType: CoinType, period: Period, completion: @escaping (Result<[ChartData], Error>) -> Void) {
        let param:RequestParam = .url(["fsym":"\(coinType.rawValue)",
                                       "tsym":"USD",
                                       "limit":"\(period.limitParameter)",
                                       "aggregate":"\(period.aggregateParameter)"])
        guard let coinChartDataURL = CoinChartDataRequest(period: .day, param: param).urlRequest()?.url else { return }
        AF.request(coinChartDataURL).responseJSON { response in
            switch response.result {
            case .success(let successData):
                let decoder = JSONDecoder()
                do {
                    let coinChartRawData = try JSONSerialization.data(withJSONObject: successData, options: .prettyPrinted)
                    let coinChartProcessedData = try decoder.decode(ChartDataResponse.self, from: coinChartRawData)
                    completion(.success(coinChartProcessedData.chartDatas))
                } catch let error {
                    print("==> coin chart decoding error: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("==> coin chart error: \(error.localizedDescription)")
            }
        }
    }
    
    static func requestNewsList(completion: @escaping (Result<[Article], Error>) -> Void) {
        guard let newsURL = NewsListRequest().urlRequest()?.url else{ return }
        AF.request(newsURL).responseJSON { response in
            switch response.result {
            case .success(let successData):
                let decoder = JSONDecoder()
                do {
                    let newsListRawData = try JSONSerialization.data(withJSONObject: successData, options: .prettyPrinted)
                    let newsListProcessedData = try decoder.decode([NewsResponse].self, from: newsListRawData)
                    completion(.success(newsListProcessedData.flatMap { $0.articleArray }))
                } catch let error {
                    print("==> news list decoding error: \(error.localizedDescription)")
                }
            case .failure(let error):
                print("==> news list error: \(error.localizedDescription)")
            }
        }
    }
}
