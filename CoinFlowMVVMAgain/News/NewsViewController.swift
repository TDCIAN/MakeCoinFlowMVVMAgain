//
//  NewsViewController.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/19.
//

import UIKit

class NewsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NetworkManager.requestNewsList { result in
            switch result {
            case .success(let articles):
                print("--> article list: \(articles.count)")
            case .failure(let error):
                print("--> article error: \(error.localizedDescription)")
            }
        }
    }
}

extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 15
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsListCell", for: indexPath) as? NewsListCell else { return UITableViewCell()
        }
        cell.backgroundColor = .randomColor()
        return cell
    }
    
    
}

class NewsListCell: UITableViewCell {
    
}
