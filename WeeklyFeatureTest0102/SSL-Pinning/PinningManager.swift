//
//  PinningManager.swift
//  WeeklyFeatureTest0102
//
//  Created by 王柏崴 on 1/3/24.
//

import Foundation
import CommonCrypto
import CryptoKit

//當 PinningManager 的 validate 方法被調用時，它將：

// 1. 檢查挑戰中是否包含憑證。
// 2. 提取憑證的公鑰。
// 3. 根據公鑰的大小決定使用哪個 ASN.1 Header。
// 4. 生成公鑰的雜湊並與預先定義的雜湊進行比較。
// 5. 如果有匹配的雜湊，則認為連接是安全的，否則拒絕連接。
// 6. 這個過程確保了與服務器的通信是安全的，並且任何未經授權的或偽造的憑證都會被拒絕。這是通過確保服務器的公鑰與客戶端預期的公鑰匹配來實現的。這是一個增強 HTTPS 安全的技術。

struct PinningManager {

    // 定義與 SSL 釘合相關的錯誤。每種錯誤都有一個自定義的描述，這樣當錯誤發生時，可以提供更清晰的信息。
    private enum PinningError: Error {
        
        // 無法從服務器獲取證書。
        case noCertificatesFromServer
        // 無法獲取公鑰。
        case failedToGetPublicKey
        // 無法從公鑰提取數據。
        case failedToGetDataFromPublicKey
        // 收到了錯誤的證書。
        case receivedWrongCertificate
        // 無法獲取公鑰大小。
        case failedToGetPublicKeySize
        
        var localizedDescription: String {
            switch self {
            case .noCertificatesFromServer: return "Can not retrieve certificate"
            case .failedToGetPublicKey: return "Public Key (PK) could not fetch"
            case .failedToGetDataFromPublicKey: return "Can not extract data from Public Key"
            case .receivedWrongCertificate: return "Wrong Certificate"
            case .failedToGetPublicKeySize: return "Can not retrieve key size"
            }
        }
    }
    
    //定義了兩種公鑰的 ASN.1 Header。ASN.1 是一種標準化的格式，用於描述數據結構的語法。這裡的Header數據被用於在生成公鑰雜湊時添加到公鑰數據前面。
    /// - Parameter bytes: 提供每種密鑰類型對應的 ASN.1 Header字節數組。
    private enum ASN1Header {
        
        case rsa2048
        case rsa4096
        
        var bytes: [UInt8] {
            switch self {
            case .rsa2048:
                // 2048 位 RSA 密鑰的 ASN.1 Header。
                return [0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
                        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00]
                
            case .rsa4096:
                // 4096 位 RSA 密鑰的 ASN.1 Header。
                return [0x30, 0x82, 0x02, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
                        0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x02, 0x0f, 0x00]
            }
        }
    }
    
    //pinnedKeyHashes 存儲已經過雜湊的公鑰字符串的陣列，這些是進行憑證釘合時要匹配的預期公鑰雜湊值。
    private var pinnedKeyHashes: [String]!

    // 初始化器接受一個公鑰雜湊的陣列來設置預期的公鑰。
    init(pinnedKeyHashes: [String]) {
        self.pinnedKeyHashes = pinnedKeyHashes
    }

    // 允許更新要釘合的公鑰的雜湊值。
    /// - Parameter pk: String...
    mutating func setNewPK(_ pk: String...) {
        pinnedKeyHashes = pk
    }
    
    // 計算給定數據的 SHA256 雜湊值。這是生成公鑰雜湊的關鍵步驟。
    // 這個雜湊值可以被用來驗證訊息的完整性，因為即使是對訊息的微小變動，也會產生一個不同的雜湊值。
    /// - Parameters:
    ///   - digiest: 初始化一個 UInt8 陣列來存儲雜湊計算的結果。CC_SHA256_DIGEST_LENGTH 定義了 SHA256 輸出的字節長度。
    ///   - data: 要進行雜湊計算的數據。這通常是連接 ASN.1 Header數據和公鑰數據後的結果。:
    /// - Returns: 代表雜湊值的 `Data` 對象，通常用於 SSL 釘合來比較服務器憑證的公鑰雜湊。
    private func sha256(_ data: Data) -> Data {
        
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = data.withUnsafeBytes { buffer in
            CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        
        return Data(bytes: digest, count: digest.count)
    }
    
    // 根據公鑰的大小，確定用於生成雜湊的 ASN.1 Header數據。
    /// - Parameter key: 從服務器證書中提取的公鑰Public Key (PK)，將被用來確定其對應的 ASN.1 Header。
    /// - Returns: ASN.1 Header數據，用於公鑰雜湊的生成。
    /// - Throws: 如果公鑰的大小不是預期的值，則拋出 `PinningError.failedToGetPublicKeySize` 錯誤。
    private func getSecKeyBlockSize(_ key: SecKey) throws -> ASN1Header {
        
        let size = SecKeyGetBlockSize(key)
        
        if size == 256 {
            return .rsa2048
        }
        
        if size == 512 {
            return .rsa4096
        }
        
        throw PinningError.failedToGetPublicKeySize
    }
    
    /// 處理收到的 SSL 認證挑戰，並確定是否可以信任該服務器。
    /// - Parameters:
    ///   - challenge: 包含了服務器提供的證書信息的認證挑戰。(URLAuthenticationChallenge)
    ///   - completionHandler: 一旦完成憑證的驗證，將通過這個閉包回調來繼續處理或取消請求。(URLSession.AuthChallengeDisposition, URLCredential?)
    func validate(challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        do {
            let trust = try validateAndGetTrust(with: challenge)
            
            completionHandler(.performDefaultHandling, URLCredential(trust: trust))
        } catch {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    /// 從認證挑戰中提取出 `SecTrust` 對象，用於後續的憑證驗證。
    /// - Parameters:
    ///   - challenge: 包含了從服務器接收到的憑證信息的認證挑戰，這個對象包含了必要的信息來進行憑證驗證流程。
    ///   - trust: 一個 `SecTrust` 對象，包含了證書鏈和驗證策略，可以用來評估是否應該信任服務器憑證。
    ///   - trustCertificateChain: 一個 `SecCertificate` 對象陣列，包含了從證書鏈中提取出的所有證書。
    /// - Returns: 從挑戰中提取的 `SecTrust` 對象，其中包含了服務器的證書鏈。
    /// - Throws: 如果無法從挑戰中獲取 `SecTrust` 對象，則拋出 `PinningError.noCertificatesFromServer` 錯誤。
    private func validateAndGetTrust(with challenge: URLAuthenticationChallenge) throws -> SecTrust {
        
        guard let trust = challenge.protectionSpace.serverTrust else {
            throw PinningError.noCertificatesFromServer
        }
        
        var trustCertificateChain: [SecCertificate] = []

        if #available(iOS 12.0, *) {

                for index in 0..<3 {
                //0 > RSA 2048 bits (e 65537) / SHA256withRSA
                //1 > 2048 bits (e 65537) / SHA384withRSA
                //2 > RSA 4096 bits (e 65537) / SHA384withRSA
                if let cert = SecTrustGetCertificateAtIndex(trust, index) { // RSA 2048 bits (e 65537) / SHA256withRSA
                    trustCertificateChain.append(cert)
                }
            }
        }
        
        if #available(iOS 15.0, *) {
            trustCertificateChain = SecTrustCopyCertificateChain(trust) as! [SecCertificate]
        }
        
        for serverCertificate in trustCertificateChain {
            let publicKey = try getPublicKey(for: serverCertificate)
            let header = try getSecKeyBlockSize(publicKey)
            let publicKeyHash = try getKeyHash(of: publicKey, header: header)
            
            if pinnedKeyHashes.contains(publicKeyHash) {
                return trust
            }
        }
        
        
        throw PinningError.receivedWrongCertificate
    }
    
    /// 從提供的 `SecCertificate` 中提取公鑰，用於憑證驗證和公鑰雜湊比對。
    /// - Parameters:
    ///   - certificate: 一個 `SecCertificate` 對象，代表從服務器接收到的 SSL/TLS 憑證。
    ///   - trust: 可選的 `SecTrust` 對象，如果已經從證書創建過，則可以用於提取公鑰。
    ///   - policy: 一個驗證策略，通常是 `SecPolicyCreateBasicX509()`，用於憑證的驗證。
    ///   - publicKey: 從證書提取的 `SecKey` 對象，包含了公鑰信息。
    /// - Returns: 從證書中提取出的公鑰 `SecKey` 對象。
    /// - Throws: 如果無法從證書中提取公鑰，則拋出 `PinningError.failedToGetPublicKey` 錯誤。
    private func getPublicKey(for certificate: SecCertificate) throws -> SecKey {
        
        let policy = SecPolicyCreateBasicX509()
        var trust: SecTrust?
        
        let trustCreationStatus = SecTrustCreateWithCertificates(certificate, policy, &trust)

        if let trust, trustCreationStatus == errSecSuccess {
            var publicKey: SecKey?
            
            if #available(iOS 15, *) {
                publicKey = SecTrustCopyKey(trust)
            }
            
            if #available(iOS 12, *) {
                publicKey = SecCertificateCopyKey(certificate)
            }
            
            if publicKey == nil {
                throw PinningError.failedToGetPublicKey
            }
            
            return publicKey!
        } else {
            
            throw PinningError.failedToGetPublicKey
        }
    }
    
    // 計算公鑰雜湊並將其與預設的釘合公鑰進行比對，以確認是否為預期的公鑰。
    /// - Parameters:
    ///  - publicKey: 從證書中提取出的 `SecKey` 對象，包含了公鑰信息。
    ///  - publicKeyCFData: 公鑰的外部表示形式，為一串字節數據，用於計算雜湊值。
    ///  - publicKeyData: 將 `publicKeyCFData` 轉換為 `Data` 對象後的結果，方便進行雜湊計算。
    ///  - publicKeyWithHeaderData: 將 ASN.1 頭部數據和 `publicKeyData` 組合後的數據，用於計算雜湊。
    ///  - header: 根據公鑰大小確定的 ASN.1 頭部數據。這些數據在計算公鑰雜湊時需要與公鑰本身組合使用。
    /// - Returns: 公鑰雜湊的 Base64 編碼字符串。這個字符串用於比對預設的釘合公鑰雜湊值，
    ///   以確認服務器憑證的公鑰是否為期望的那個。
    /// - Throws: 如果無法從公鑰提取數據或無法計算雜湊，則拋出 `PinningError.failedToGetDataFromPublicKey` 或
    ///   `PinningError.failedToGetPublicKeySize` 錯誤。
    private func getKeyHash(of publicKey: SecKey, header: ASN1Header) throws -> String {
        
        guard let publicKeyCFData = SecKeyCopyExternalRepresentation(publicKey, nil) else {
            throw PinningError.failedToGetDataFromPublicKey
        }
        
        let publicKeyData = (publicKeyCFData as NSData) as Data
        
        var publicKeyWithHeaderData: Data
        publicKeyWithHeaderData = Data(header.bytes)
    
        publicKeyWithHeaderData.append(publicKeyData)
        let publicKeyHashData = sha256(publicKeyWithHeaderData)
        
        return publicKeyHashData.base64EncodedString()
    }
}
