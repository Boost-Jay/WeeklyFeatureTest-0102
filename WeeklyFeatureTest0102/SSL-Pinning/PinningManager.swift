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
// 3. 根據公鑰的大小決定使用哪個 ASN.1 頭部。
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
    
    //定義了兩種公鑰的 ASN.1 頭部。ASN.1 是一種標準化的格式，用於描述數據結構的語法。這裡的頭部數據被用於在生成公鑰雜湊時添加到公鑰數據前面。
    private enum ASN1Header {
        
        case rsa2048
        case rsa4096
        
        var bytes: [UInt8] {
            switch self {
            case .rsa2048:
                return [0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00]
                
            case .rsa4096:
                return [0x30, 0x82, 0x02, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x02, 0x0f, 0x00]
            }
        }
    }
    
    //pinnedKeyHashes 是一個存儲已經過雜湊的公鑰字符串的陣列。這些是要匹配的預期公鑰。
    /// Pinlenecek Public Key Hashleri
    private var pinnedKeyHashes: [String]!

    //接受一個公鑰雜湊的陣列。
    init(pinnedKeyHashes: [String]) {
        self.pinnedKeyHashes = pinnedKeyHashes
    }

    //允許你更改或更新要釘合的公鑰。
    /// - Parameter pk: String...
    mutating func setNewPK(_ pk: String...) {
        pinnedKeyHashes = pk
    }
    
    //方法用於計算給定數據的 SHA256 雜湊值。這通常用於生成公鑰的雜湊。
    /// - Parameter data: ASN1Header ve PublicKey'in datası eklenerek
    /// - Returns: PublicKey Hash
    private func sha256(_ data: Data) -> Data {
        
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        
        _ = data.withUnsafeBytes { buffer in
            CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &digest)
        }
        
        return Data(bytes: digest, count: digest.count)
    }
    
    /// PublicKey Hashe Göre ASN.1 Header verilir
    /// - Parameter key: Public Key (PK)
    /// - Returns: ASN.1 Header
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
    
    //當接收到 SSL 挑戰時會調用的方法。它會試圖驗證接收到的憑證是否可信。
    ///   - challenge: URLAuthenticationChallenge
    ///   - completionHandler: (URLSession.AuthChallengeDisposition, URLCredential?)
    func validate(challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        do {
            let trust = try validateAndGetTrust(with: challenge)
            
            completionHandler(.performDefaultHandling, URLCredential(trust: trust))
        } catch {
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
    
    /// URL'den Trust seritifkaları alınır
    /// - Parameter challenge: URLAuthenticationChallenge
    /// - Returns: SecTrust
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
    
    //用於從 SecCertificate 對象中提取公鑰。這個公鑰隨後會用於生成雜湊並與預期的雜湊進行比較。
    /// - Parameter certificate: SecCertificate
    /// - Returns: SecKey
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
    
    //結合公鑰和 ASN.1 頭部數據，生成一個新的數據對象，然後對這個新的數據對象計算 SHA256 雜湊
    //最終，這個雜湊被轉換成一個 Base64 編碼的字符串，這是一種網絡傳輸常用的編碼格式。
    /// - Parameters:
    ///   - publicKey: SecKey
    ///   - header: ASN1Header
    /// - Returns: String
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
