//
//  Connectivity.swift
//  Pin It
//
// Suggested at https://stackoverflow.com/questions/41327325/how-to-check-internet-connection-in-alamofire

import Foundation
import Alamofire

class Connectivity {
    class var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
