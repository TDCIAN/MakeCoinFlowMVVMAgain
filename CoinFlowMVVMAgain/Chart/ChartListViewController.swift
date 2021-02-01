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
    
    var viewModel: ChartListViewModel!
    
//    var coinInfoList: [CoinInfo] = [] {
//        // data가 세팅이 되면 didSet
//        didSet {
//            // data 세팅이 되면 테이블뷰 리스트 다시 그리기, 테이블뷰 리로드
//            DispatchQueue.main.async {
//                self.chartCollectionView.reloadData()
//                self.chartTableView.reloadData()
//                self.adjustTableViewHeight()
//            }
//        }
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = ChartListViewModel(changeHandler: { coinInfos in
            DispatchQueue.main.async {
                self.chartCollectionView.reloadData()
                self.chartTableView.reloadData()
                self.adjustTableViewHeight()
            }
        })
        viewModel.fetchData()

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
        return viewModel.numberOfCoinInfoList
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChartCardCell", for: indexPath) as? ChartCardCell else { return UICollectionViewCell() }
        let coinInfo = viewModel.coinInfo(at: indexPath)
        cell.viewModel = ChartCardCellViewModel(coinInfo: coinInfo, chartDatas: [], selectedPeriod: .week, changeHandler: { _, _ in })
        cell.viewModel.updateNotify { chartDatas, selectedPeriod in
            cell.renderChart(with: chartDatas, period: selectedPeriod)
        }
        cell.viewModel.fetchData()
        cell.updateCoinInfo(cell.viewModel)
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
        showDetail(coinInfo: viewModel.coinInfo(at: indexPath))
    }
}



// MARK: - Table View
extension ChartListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfCoinInfoList
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewModel.cell(for: indexPath, at: tableView)
        return cell
    }
}

extension ChartListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showDetail(coinInfo: viewModel.coinInfo(at: indexPath))
    }
}
