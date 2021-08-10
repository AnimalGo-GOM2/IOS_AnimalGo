//
//  BaseViewController.swift
//  AnimalGo
//
//  Created by Kiwon on 16/07/2019.
//  Copyright © 2019 AnimalGo. All rights reserved.
//

import UIKit
import WebKit
import OneSignal
import NotificationCenter
import Alamofire

class BaseViewController: UIViewController {
    
    var webView: BaseWKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    public func showSystemAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let comfirmAction = UIAlertAction(title: Text.move.name, style: .default) { (action) in
            self.openURL(urlStr: UIApplication.openSettingsURLString)
        }
        let cancelAction = UIAlertAction(title: Text.cancel.name, style: .cancel, handler: nil)
        
        alert.addAction(comfirmAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    public func openURL(urlStr: String) {
        if let url = URL(string: urlStr),
            UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    public func setPushID() {
        self.webView.evaluateJavaScript("localStorage.getItem(\"pushid\")") { (result, error) in
            print("pushToken = \(result as? String ?? " Empty ")")
            if result as? String == nil {
                let status: OSPermissionSubscriptionState = OneSignal.getPermissionSubscriptionState()
                if status.permissionStatus.status == .notDetermined || status.permissionStatus.status == .denied { return }
                guard let pushToken = status.subscriptionStatus.userId else { return }
                print("pushToken = \(pushToken)")
                self.webView.evaluateJavaScript("localStorage.setItem(\"pushid\", '" + pushToken + "')") { (result, error) in
                }
            }
        }
    }
}

// MARK:- Popup
extension BaseViewController {
    func popupOneBtn(withTitle title: String, msg: String, buttonAction: VoidClosure? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let action = UIAlertAction(title: Text.comfirm.name, style: .default) { (alert) in
            if let buttonAct = buttonAction { buttonAct() }
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func popupTwoBtn(title: String, msg: String, leftBtnAction: VoidClosure? = nil, rightBtnAction: VoidClosure? = nil) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
        let leftAction = UIAlertAction(title: Text.cancel.name, style: .default) { (alert) in
            if let buttonAct = leftBtnAction { buttonAct() }
        }
        let rightAction = UIAlertAction(title: Text.comfirm.name, style: .default) { (alert) in
            if let buttonAct = rightBtnAction { buttonAct() }
        }
        alert.addAction(leftAction)
        alert.addAction(rightAction)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK:- WKUIDelegate
extension BaseViewController: WKUIDelegate {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.url else {
            return nil
        }
        // target = _blank tag 호출시
        guard let targetFrame = navigationAction.targetFrame, targetFrame.isMainFrame  else  {
            self.webView.openApp(withScheme: url.absoluteString, moreString: nil)
            return nil
        }
        return nil
    }
    
    // JavaScript 확인 얼럿
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        popupOneBtn(withTitle: message, msg: "") {
            completionHandler()
        }
    }
    
    // JAvaScript 확인/취소 얼럿
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        popupTwoBtn(title: message, msg: "", leftBtnAction: {
            completionHandler(false)
        }, rightBtnAction: {
            completionHandler(true)
        })
    }
    
    // JAvaScript TextField 얼럿
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        
        let alertController = UIAlertController(title: frame.request.url?.host, message: prompt, preferredStyle: .alert)
        weak var alertTextField: UITextField!
        alertController.addTextField { textField in
            textField.text = defaultText
            alertTextField = textField
        }
        alertController.addAction(UIAlertAction(title: Text.cancel.name, style: .cancel, handler: { action in
            completionHandler(nil)
        }))
        alertController.addAction(UIAlertAction(title: Text.comfirm.name, style: .default, handler: { action in
            completionHandler(alertTextField.text)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}

// MARK:- WKNavigationDelegate
extension BaseViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        
        let urlElements = url.absoluteString.components(separatedBy: ":")
        switch urlElements[0] {
            
        case "tel", "sms", "mailto", "itmss" :
            self.webView.openApp(withScheme: url.absoluteString, moreString: nil)
            decisionHandler(.cancel)
            return
            
        default:
            break
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
//        print("navigationResponse")
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        print("didStartProvisionalNavigation")
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        print("didCommit")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // 웹뷰에서 롱클릭에 대한 이벤트를 막아준다.
//        print("didFinish")
        webView.evaluateJavaScript("document.body.style.webkitTouchCallout='none';")
        setPushID()
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("Error WebView : \(error.localizedDescription)")
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
//        print("didReceive")
        switch (challenge.protectionSpace.authenticationMethod) {
        case NSURLAuthenticationMethodHTTPBasic:
            let alertController = UIAlertController(title: "Authentication Required", message: webView.url?.host, preferredStyle: .alert)
            weak var usernameTextField: UITextField!
            alertController.addTextField { textField in
                textField.placeholder = "Username"
                usernameTextField = textField
            }
            weak var passwordTextField: UITextField!
            alertController.addTextField { textField in
                textField.placeholder = "Password"
                textField.isSecureTextEntry = true
                passwordTextField = textField
            }
            alertController.addAction(UIAlertAction(title: Text.cancel.name, style: .cancel, handler: { action in
                completionHandler(.cancelAuthenticationChallenge, nil)
            }))
            alertController.addAction(UIAlertAction(title: Text.login.name, style: .default, handler: { action in
                guard let username = usernameTextField.text, let password = passwordTextField.text else {
                    completionHandler(.rejectProtectionSpace, nil)
                    return
                }
                let credential = URLCredential(user: username, password: password, persistence: URLCredential.Persistence.forSession)
                completionHandler(.useCredential, credential)
            }))
            present(alertController, animated: true, completion: nil)
            
        default:
            completionHandler(.rejectProtectionSpace, nil);
        }
    }
}

// MARK:- WKScriptMessageHandler
extension BaseViewController: WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        // 웹에서 Javascript로 iOS Method를 호출 할 수 있다.
        // if message.name == "웹과 통신할 키값" { }
    }
}

extension BaseViewController {
    
    /**
     Image Upload to server
     
     - parameter imageData:    선택한 이미지 데이터 파일
     - parameter fileName:     이미지 파일 이름
     - parameter mimeType:     파일 타입 (jpg, png, gif)
     - parameter rotation:     사진이 회전된 방향
     - parameter successBlock: 업로드 Success 블럭
     - parameter failBlock:    업로드 faill 블럭
     */
    class func requestImageData(_ imageData: Data, fileName: String, mimeType: String, rotation: Int, successBlock: @escaping (String) -> Void, failBlock: @escaping () -> Void) {
        
        print("===========File Upload=========\n file Name : \(fileName) \n file Type : \(mimeType)")
        
        let headers = [
            "Content-Disposition": "form-data; name=uploadimg; filename=\"\(fileName)\"; rotation=\"\(rotation)\"",
            "Content-Type": "\(mimeType)"]
        let stream = InputStream(data: imageData)
        let length = UInt64(imageData.count)
        
        Alamofire.upload(multipartFormData: { (multipartFormData) in
            multipartFormData.append(stream, withLength: length, headers: headers)},
                         to: "이미지 서버 URL",
                         method: .post,
                         encodingCompletion: { (encodingResult) in
                            switch encodingResult {
                            case .success(let upload, _, _):
                                upload.responseJSON { response in
                                    print("===========response======\n\(response)")
                                    guard let result = (response.result.value as AnyObject).value(forKey: "result") else {
                                        failBlock()
                                        return
                                    }
                                    if result as! String == "ok" {
                                        guard let filename = (response.result.value as AnyObject).value(forKey: "filename") else {
                                            failBlock()
                                            return
                                        }
                                        successBlock(filename as! String)
                                    } else {
                                        failBlock()
                                    }
                                }
                            case .failure(let encodingError) :
                                print(encodingError)
                                failBlock()
                            }
        })
    }
}
