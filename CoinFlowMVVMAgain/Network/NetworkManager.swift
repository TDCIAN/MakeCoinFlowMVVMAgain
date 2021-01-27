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
    
    static func requestCoinList(completion: @escaping ([Coin]) -> Void) {
        let coinListURL = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=BTC,ETH,DASH,LTC,ETC,XRP,BCH,XMR,QTUM,ZEC,BTG&tsyms=USD")!
        let taskWithCoinListURL = session.dataTask(with: coinListURL) { (data, response, error) in
            let successRange = 200..<300
            guard error == nil,
                  let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  successRange.contains(statusCode) else {
                return
            }
            
            guard let responseData = data else{ return }
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(CoinListResponse.self, from: responseData)
                print("--> success: \(response.raw.btg)")
                let coinList = response.raw.allCoins()
                completion(coinList)
            } catch {
                print("--> error: \(error.localizedDescription)")
            }
            
        }
        taskWithCoinListURL.resume()
    }
    
    static func requestCoinChartData(completion: @escaping ([ChartData]) -> Void) {
        let coinChartDataURL = URL(string: "https://min-api.cryptocompare.com/data/histohour?fsym=BTC&tsym=USD&limit=24")!
        let taskWithCoinChartDataURL = session.dataTask(with: coinChartDataURL) { (data, response, error) in
            let successRange = 200..<300
            guard error == nil,
                  let statusCode = (response as? HTTPURLResponse)?.statusCode,
                  successRange.contains(statusCode) else {
                return
            }
            guard let responseData = data else { return }
            let decoder = JSONDecoder()
            do {
                let response = try decoder.decode(ChartDataResponse.self, from: responseData)
                let chartDatas = response.chartDatas
                completion(chartDatas)
            } catch {
                print("--> err: \(error.localizedDescription)")
            }
        }
        taskWithCoinChartDataURL.resume()
    }
    
    
    
}
