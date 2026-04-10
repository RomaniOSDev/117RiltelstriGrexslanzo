//
//  LoadingManager.swift
//  117RiltelstriGrexslanzo
//


import UIKit
import SwiftUI


final class LoadingManager {

    static let shared = LoadingManager()

    private init() {}

    func makeRootViewController() -> UIViewController {
        return LoadingViewController()
    }
}
