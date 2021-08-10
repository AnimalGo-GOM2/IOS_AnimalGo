//
//  MainWebViewController.swift
//  AnimalGo
//
//  Created by Kiwon on 16/07/2019.
//  Copyright © 2019 AnimalGo. All rights reserved.
//

import UIKit
import WebKit

class MainWebViewController: BaseViewController {

    @IBOutlet weak var baseView: UIView!
    
    /// Splash View
    var splashView: SplashView?
    
    private let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 스플래쉬뷰
        showSplashView()

        // imagePicker 설정
        self.imagePicker.delegate = self
        
        // webView 설정
        guard let url = URL.init(string: URL_HOME) else { return }
        var request = URLRequest.init(url: url)
        request.httpShouldHandleCookies = true
        
        self.webView = BaseWKWebView.init()
        self.webView.uiDelegate = self
        self.webView.navigationDelegate = self
        self.baseView.addSubview(self.webView)
        self.webView.setAutolayout(withView: self.baseView)
        self.webView.load(request)
    }
    
    func reloadURL(_ pushURL: String) {
        guard let url = URL.init(string: pushURL) else { return }
        var request = URLRequest.init(url: url)
        request.httpShouldHandleCookies = true
        self.webView.load(request)
    }
    
    /// 스플래시 띄우기
    private func showSplashView() {
        self.splashView = SplashView(frame: self.view.frame)
        self.view.addSubview(self.splashView!)
        self.splashView?.startAnimation()
    }
    
    /// 스플래시 사라지게
    private func hideSplashView() {
        if let splashView = self.splashView {
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.3, animations: {
                    splashView.alpha = 0.0
                }) { (success) in
                    splashView.removeFromSuperview()
                }
            }
        }
    }
    
    private func openCamera() {
        PermissionManager.authorizationCamera(success: {
            // 성공
            self.imagePicker.sourceType = .camera
            self.imagePicker.cameraCaptureMode = .photo
            self.present(self.imagePicker, animated: true, completion: nil)
        }) {
            // 실패
            self.showSystemAlert(title: Text.setting.name, message: Text.settingForCamera.name)
        }
    }
    
    private func openLibrary() {
        PermissionManager.authorizationAlbum(success: {
            // 성공
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }) {
            // 실패
            self.showSystemAlert(title: Text.setting.name, message: Text.settingForLibrary.name)
        }
    }
}

// MARK:- WkWebViewDelegate
extension MainWebViewController {
    override func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        super.webView(webView, didFinish: navigation)
//        hideSplashView()
    }
}

// MARK:- UIImagePickerControllerDelegate
extension MainWebViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 이미지 선택이 완료 되면,
        
        if let cropImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            print(String.init(format: "cropImage = %@", cropImage))
            print(info)
        } else if let originImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            print(String.init(format: "cropImage = %@", originImage))
            print(info)
        }

        dismiss(animated: true, completion: nil)
    }
}

