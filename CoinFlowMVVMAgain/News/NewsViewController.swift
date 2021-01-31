//
//  NewsViewController.swift
//  CoinFlowMVVMAgain
//
//  Created by APPLE on 2021/01/19.
//

import UIKit
import SafariServices

class NewsViewController: UIViewController {
    
    @IBOutlet weak var newsTableView: UITableView!
    
    var viewModel: NewsListViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = NewsListViewModel(changeHandler: { articles in
            DispatchQueue.main.async {
                self.newsTableView.reloadData()
            }
        })
        viewModel.fetchData()
    }
}

extension NewsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = viewModel.cell(for: indexPath, at: tableView)
        return cell
    }
}

extension NewsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let article = viewModel.article(at: indexPath)

        guard let articleURL = URL(string: article.link) else { return }

        let config = SFSafariViewController.Configuration()
        config.entersReaderIfAvailable = true
        let safari = SFSafariViewController(url: articleURL, configuration: config)

        safari.preferredBarTintColor = UIColor.white
        safari.preferredControlTintColor = UIColor.systemBlue

        present(safari, animated: true, completion: nil)
        
    }
}

