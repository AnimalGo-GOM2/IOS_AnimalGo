//
//  Constants.swift
//  AnimalGo
//
//  Created by Kiwon on 16/07/2019.
//  Copyright © 2019 AnimalGo. All rights reserved.
//

import Foundation

typealias VoidClosure = () -> Swift.Void

let IMAGE_UPLOAD_MESSAGE = "animalgo_image_upload"

let URL_HOME = "https://animalgo.io/animalgo/"

enum Url: String {
    case home = "animalgo/"
    case tabbar_home = "board/follow_post_list/"
    case tabbar_search = "/animalgo/"
    case tabbar_write = "board/add/"
    case tabbar_favorit = "accounts/history/"
    case tabbar_my = "board/list/"
    
    var value: String { return URL_HOME + self.rawValue }
}

let ONE_SIGNAL_APP_ID = "41ba1b96-d8be-44e3-9e18-8a70c275fece"

enum Text: String {
    case alertTitle = "사진을 첨부합니다."
    case alertMsg = ""
    
    case settingForCamera = "카메라 기능을 사용하려면\n'카메라' 접근권한을 허용해야 합니다."
    case settingForLibrary = "사진 저장 기능을 사용하려면\n'앨범' 접근권한을 허용해야 합니다."
    
    case library = "앨범에서 가져오기"
    case camera = "사진찍기"
    case cancel = "취소"
    case login = "로그인"
    case comfirm = "확인"
    case move = "이동"
    case notice = "알림"
    case setting = "설정"
    
    var name: String { return self.rawValue }
}
