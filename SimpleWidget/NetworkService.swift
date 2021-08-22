//
//  NetworkService.swift
//  SimpleWidgetExtension
//
//  Created by Itamar Biton on 13/07/2021.
//

import Foundation
import WidgetKit
import os

class NetworkService: NSObject {
    static let shared = NetworkService()

    static let urlSessionIdentifier = "MySession"

    var backgroundCompletionHandler: (() -> Void)?

    private lazy var urlSession: URLSession = {
        let config = URLSessionConfiguration.background(withIdentifier: Self.urlSessionIdentifier)
        config.sessionSendsLaunchEvents = true
        return URLSession(configuration: config, delegate: self, delegateQueue: nil)
    }()

    func fetchData() {
        guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1") else { return }
        let task = urlSession.downloadTask(with: url)
        task.resume()
    }
}

extension NetworkService: URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        os_log("@@ DOWNLOADED DATA!")

        DiskService.moveFetchedDataToDataDirectory(from: location)

        WidgetCenter.shared.reloadAllTimelines()

        backgroundCompletionHandler?()
    }
}
