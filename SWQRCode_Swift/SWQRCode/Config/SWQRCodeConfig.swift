//
//  SWQRCodeConfig.swift
//  SWQRCode_Swift
//
//  Created by zhuku on 2018/4/11.
//  Copyright © 2018年 selwyn. All rights reserved.
//

import UIKit

/// 扫描器类型
///
/// - qr: 仅支持二维码
/// - bar: 仅支持条码
/// - both: 支持二维码以及条码
enum SWScannerType {
    case qr
    case bar
    case both
}

/// 扫描区域
///
/// - def: 扫描框内
/// - fullscreen: 全屏
enum SWScannerArea {
    case def
    case fullscreen
}

struct SWQRCodeCompat {
    /// 扫描器类型 默认支持二维码以及条码
    var scannerType: SWScannerType = .both
    /// 扫描区域
    var scannerArea: SWScannerArea = .def
    
    /// 棱角颜色 默认RGB色值 r:63 g:187 b:54 a:1.0
    var scannerCornerColor: UIColor = UIColor(red: 63/255.0, green: 187/255.0, blue: 54/255.0, alpha: 1.0)
    
    /// 边框颜色 默认白色
    var scannerBorderColor: UIColor = .white
    
    /// 指示器风格
    var indicatorViewStyle: UIActivityIndicatorViewStyle = .whiteLarge
}
