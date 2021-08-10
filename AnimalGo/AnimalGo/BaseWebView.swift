//
//  BaseWebView.swift
//  AnimalGo
//
//  Created by Kiwon on 16/07/2019.
//  Copyright © 2019 AnimalGo. All rights reserved.
//

import UIKit
import WebKit

class BaseWKWebView: WKWebView {
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        let userController: WKUserContentController = WKUserContentController()
        
        // Javascript로 iOS Method를 호출하기 위한 handler 설정
        //            userController.add(self, name: _CALL_APP_IMAGE_KEY_)
        
        // iOS 결제앱을 불러오기 위해 앱 Scheme값을 웹으로 전달한다.
        //            let userScript = WKUserScript(
        //                source: "shcemeIos('ciangsiosforjunior://')",
        //                injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
        //                forMainFrameOnly: true
        //            )
        //            userController.addUserScript(userScript)
        
        configuration.userContentController = userController;
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        
        super.init(frame: frame, configuration: configuration)
    }
    
    convenience init() {
        self.init(frame: .zero, configuration: WKWebViewConfiguration())
        self.backgroundColor = .white
        self.scrollView.backgroundColor = .white
        self.allowsBackForwardNavigationGestures = false
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.bounces = false
        self.isOpaque = false
    }
}

// MARK:- Public function
extension BaseWKWebView {
    
    class public func deleteCache() {
        let websiteDataTypes = NSSet(array: [WKWebsiteDataTypeDiskCache, WKWebsiteDataTypeMemoryCache])
        let date = NSDate(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: websiteDataTypes as! Set<String>, modifiedSince: date as Date, completionHandler:{ })
    }
    
    public func setAutolayout(withView view: UIView) {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        self.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        self.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    public func openApp(withScheme urlScheme: String, moreString: String?) {
        guard let url = URL.init(string: urlScheme + (moreString ?? "")) else {
            return
        }
        
        let application = UIApplication.shared
        if application.canOpenURL(url) {
            application.open(url, options: [:], completionHandler: nil)
        }
    }
    
    public func callJavaScript(functionName: String) {
        //        let js:String = String(format: "ajaxSetting.imgHTML('%@');", imageURL)
        self.evaluateJavaScript(functionName) { (AnyObject, NSError) in
            print("function \(#function)")
        }
    }
    
    func loadQueryString(withRequest request: URLRequest, url: URL) {
        let task = URLSession.shared.dataTask(with: request) { (data : Data?, response : URLResponse?, error : Error?) in
            if data != nil {
                if let returnString = String(data: data!, encoding: .utf8) {
                    print("loadQueryString : " + returnString)
                    DispatchQueue.main.async {
                        self.loadHTMLString(returnString, baseURL: url)
                    }
                }
            }
        }
        task.resume()
    }
}

// MARK:- Private Function
extension BaseWKWebView {
    
    fileprivate func setWkWebViewConf() -> WKWebViewConfiguration{
        let webCfg:WKWebViewConfiguration = WKWebViewConfiguration()
        webCfg.websiteDataStore = WKWebsiteDataStore.default()
        
        let userController:WKUserContentController = WKUserContentController()
        
        // Javascript로 iOS Method를 호출하기 위한 handler 설정
        //            userController.add(self, name: _CALL_APP_IMAGE_KEY_)
        
        // iOS 결제앱을 불러오기 위해 앱 Scheme값을 웹으로 전달한다.
        //            let userScript = WKUserScript(
        //                source: "shcemeIos('ciangsiosforjunior://')",
        //                injectionTime: WKUserScriptInjectionTime.atDocumentEnd,
        //                forMainFrameOnly: true
        //            )
        //            userController.addUserScript(userScript)
        
        webCfg.userContentController = userController;
        webCfg.preferences.javaScriptCanOpenWindowsAutomatically = true
        HTTPCookieStorage.shared.cookieAcceptPolicy = .always
        return webCfg
    }
}

// MARK:- WKScriptMessageHandler
extension BaseWKWebView: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("Firebese")
    }
}
