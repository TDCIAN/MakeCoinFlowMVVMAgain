//
//  ChartListViewController.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/19.
//

import UIKit
import Charts

typealias CoinInfo = (key: CoinType, value: Coin)

class ChartListViewController: UIViewController {
    
    @IBOutlet weak var chartCollectionView: UICollectionView!
    @IBOutlet weak var chartTableView: UITableView!
    @IBOutlet weak var chartTableViewHeight: NSLayoutConstraint!
    
    var coinInfoList: [CoinInfo] = [] {
        // data가 세팅이 되면 didSet
        didSet {
            // data 세팅이 되면 테이블뷰 리스트 다시 그리기, 테이블뷰 리로드
            DispatchQueue.main.async {
                self.chartCollectionView.reloadData()
                self.chartTableView.reloadData()
                self.adjustTableViewHeight()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}

// MARK: - Private Method
extension ChartListViewController {
    private func adjustTableViewHeight() {
        chartTableViewHeight.constant = chartTableView.contentSize.height
    }
    
    private func showDetail(coinInfo: CoinInfo) {
        let storyboard = UIStoryboard(name: "Chart", bundle: .main)
        if let detailVC = storyboard.instantiateViewController(withIdentifier: "ChartDetailViewController") as? ChartDetailViewController {
            detailVC.viewModel = ChartDetailViewModel(coinInfo: coinInfo, chartDatas: [], selectedPeriod: .day, changeHandler: { _, _ in })
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - Collection View
extension ChartListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return coinInfoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChartCardCell", for: indexPath) as? ChartCardCell else { return UICollectionViewCell() }
        let coinInfo = coinInfoList[indexPath.row]
        cell.viewModel = ChartCardCellViewModel(coinInfo: coinInfo, chartDatas: [], selectedPeriod: .week, changeHandler: { _, _ in })
        cell.viewModel.updateNotify { chartDatas, selectedPeriod in
            cell.renderChart(with: chartDatas, period: selectedPeriod)
        }
        cell.viewModel.fetchData()
        cell.updateCoinInfo(cell.viewModel)
//        cell.updateCoinInfo(coinInfo: coinInfo)
//        cell.fetchData()
        return cell
    }
}

extension ChartListViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width: CGFloat = collectionView.frame.width - 20 * 2 - 15
        let height: CGFloat = 200
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("콜렉션뷰디드셀렉트: \(indexPath.row)")
        let coinInfo = coinInfoList[indexPath.row]
        showDetail(coinInfo: coinInfo)
    }
}



// MARK: - Table View
extension ChartListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coinInfoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ChartListCell", for: indexPath) as? ChartListCell else { return UITableViewCell()
        }
        let coinInfo = coinInfoList[indexPath.row]
        cell.configCell(coinInfo: coinInfo)
        return cell
    }
}

extension ChartListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let coinInfo = coinInfoList[indexPath.row]
        showDetail(coinInfo: coinInfo)
    }
}
