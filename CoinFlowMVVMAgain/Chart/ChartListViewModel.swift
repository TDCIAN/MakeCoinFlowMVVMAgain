//
//  ChartListViewModel.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/02/01.
//

import UIKit

class ChartListViewModel {
    typealias Handler = ([CoinInfo]) -> Void
    var changeHandler: Handler
    
    var coinInfoList: [CoinInfo] = [] {
        // data가 세팅이 되면 didSet
        didSet {
            changeHandler(coinInfoList)
        }
    }
    
    init(changeHandler: @escaping Handler) {
        self.changeHandler = changeHandler
    }
}

extension ChartListViewModel {
    func fetchData() {
        NetworkManager.requestCoinList { result in
            switch result {
            case .success(let coins):
                // cell에는 coin type과 해당 coin의 정보가 들어가야 한다
                let tuples = zip(CoinType.allCases, coins).map { (key: $0, value: $1) }
                self.coinInfoList = tuples
                
            case .failure(let error):
                print("--> coin list error: \(error.localizedDescription)")
            }
        }
    }
    
    var numberOfCoinInfoList: Int {
        return coinInfoList.count
    }
    
    func cell(for indexPath: IndexPath, at tableView: UITableView) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChartListCell", for: indexPath) as? ChartListCell else { return UITableViewCell()
        }
        let coinInfo = coinInfoList[indexPath.row]
        cell.configCell(coinInfo: coinInfo)
        return cell
    }
    
    func coinInfo(at indexPath: IndexPath) -> CoinInfo {
        let coinInfo = coinInfoList[indexPath.row]
        return coinInfo
    }
}
