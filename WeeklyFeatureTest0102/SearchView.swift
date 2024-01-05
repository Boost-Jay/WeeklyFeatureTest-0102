//
//  SearchView.swift
//  WeeklyFeatureTest0102
//
//  Created by imac-2627 on 2024/1/5.
//

import SwiftUI

/// 定義一個`Post`結構，用於表示帖子，包含使用者ID、標籤ID、標題和內容。
struct Post: Identifiable, Codable {
    let userId: Int
    let id: Int
    let title: String
    let body: String
}

// 定義一個錯誤類型，用於處理網路請求中可能出現的錯誤。
enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus
    case failedToDecodeResponse
}

/// 定義一個`WebService`類，用於從網路上下載數據。
class WebService: Codable {
    
    // 定義一個函數來異步下載數據，並且可以處理各種數據類型。
    func downloadData<T: Codable>(fromURL: String) async -> T? {
        do {
            // 嘗試創建URL，如果失敗則拋出錯誤。
            guard let url = URL(string: fromURL) else { throw NetworkError.badUrl }
            // 嘗試發出請求並接收響應。
            let (data, response) = try await URLSession.shared.data(from: url)
            // 確保收到的是有效的HTTP響應。
            guard let response = response as? HTTPURLResponse else { throw NetworkError.badResponse }
            // 檢查HTTP狀態碼是否在200至299範圍內。
            guard response.statusCode >= 200 && response.statusCode < 300 else { throw NetworkError.badStatus }
            // 嘗試將接收到的數據解碼為指定的類型。
            guard let decodedResponse = try? JSONDecoder().decode(T.self, from: data) else { throw NetworkError.failedToDecodeResponse }
                        
            
            return decodedResponse
        } catch NetworkError.badUrl {
            print("There was an error creating the URL")
        } catch NetworkError.badResponse {
            print("Did not get a valid response")
        } catch NetworkError.badStatus {
            print("Did not get a 2xx status code from the response")
        } catch NetworkError.failedToDecodeResponse {
            print("Failed to decode response into the given type")
        } catch {
            print("An error occured downloading the data")
        }
        
        return nil
    }
}

/// 定義一個`ViewModel`類，用於存儲和處理帖子數據。
class PostViewModel: ObservableObject {
    @Published var postData = [Post]()
    
    // 定義一個函數來異步獲取帖子數據。
    func fetchData() async {
        guard let downloadedPosts: [Post] = await WebService().downloadData(fromURL: "https://jsonplaceholder.typicode.com/posts") else {return}
        postData = downloadedPosts
    }
}

/// 定義`SearchView`視圖，用於顯示和過濾帖子列表。
struct SearchView: View {
    @StateObject var vm = PostViewModel() // ViewModel實例。
    @State private var textToSearch = ""  // 用戶輸入的搜尋文字。
    
    
    /// `filteredData`根據使用者輸入的文字過濾清單。
    var filteredData: [Post] {
        if textToSearch.isEmpty {
            return vm.postData
        }
        
        return vm.postData.filter { post in
            // 將使用者輸入的文字分割成單個字串，然後檢查每個單字是否都在文章內容中。
            textToSearch.split(separator: " ").allSatisfy { string in
                post.title.lowercased().contains(string.lowercased())
            }
        }
    }
        
    var body: some View {
        
        /// 用 `NavigationStack` 包裝現有清單。
        NavigationStack {
            List(filteredData) { post in
                HStack {
                    Text("\(post.userId)")
                        .padding()
                        .overlay(Circle().stroke(.blue))
                    
                    VStack(alignment: .leading) {
                        Text(post.title)
                            .bold()
                            .lineLimit(1)
                        
                        Text(post.body)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                }
            }
            .onAppear {
                if vm.postData.isEmpty {
                    Task {
                        await vm.fetchData()
                    }
                }
            }
            //顯示在清單頂部的搜尋欄。
            .searchable(text: $textToSearch, prompt: "Search")
        }
    }
}

#Preview {
    SearchView()
}
