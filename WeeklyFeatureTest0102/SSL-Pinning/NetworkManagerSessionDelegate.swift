//
//  NetworkManagerSessionDelegate.swift
//  WeeklyFeatureTest0102
//
//  Created by 王柏崴 on 1/3/24.
//

import Foundation

//提高了應用的安全性，因為它確保了通信僅限於特定的服務器，即使 DNS 發生劫持或其他形式的攻擊，也能保證連接的安全。
//提高應用通過 HTTPS 連接安全性的一種方法。
class NetworkManagerSessionDelegate: NSObject, URLSessionTaskDelegate {

    //在你的 URLSessionTask 收到一個安全驗證挑戰時被調用，比如 SSL/TLS 握手過程中的服務器身份驗證。
    func urlSession(_ session: URLSession,
                        task: URLSessionTask,
                        didReceive challenge: URLAuthenticationChallenge,
                        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        //從受信任的端點取得公鑰
        let publicKeys: [String]? = ["MIJTvqHvOoioIrufFRfk4MpBqrS2rdiVPl/s2uC/CY=",
                                     "wMTqFy9zi+jGG8qEHCAk5fh4rydPzXaLgOFdIzE2p3U=",
                                     "fFfQLjzWkam0X5MujQh6w/z/BwmPlPp16GwtlbesoE="]
        
        //如果 publicKeys 不為 nil，則創建一個 PinningManager 實例，並呼叫它的 validate 方法來驗證挑戰。
        //這個過程會檢查挑戰中提供的憑證是否與存儲在 publicKeys 中的一個公鑰匹配。如果匹配成功，則繼續正常的連接過程；如果不成功，則拒絕連接。
        if let publicKeys = publicKeys {
            let pinningManager = PinningManager(pinnedKeyHashes: publicKeys)
            pinningManager.validate(challenge: challenge, completionHandler: completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    //首先嘗試獲取一組公鑰，這些公鑰用於 SSL 憑證釘合（SSL pinning）。釘合是一種安全實踐，旨在確保你的應用僅與預期的服務器建立安全連接，防止中間人攻擊和其他類型的網絡攻擊。
}
