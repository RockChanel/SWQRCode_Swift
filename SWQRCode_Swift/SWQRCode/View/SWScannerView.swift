//
//  SWScannerView.swift
//  SWQRCode_Swift
//
//  Created by zhuku on 2018/4/11.
//  Copyright © 2018年 selwyn. All rights reserved.
//

import UIKit

private let scanner_borderWidth: CGFloat = 1.0  /** 扫描器边框宽度 */
private let scanner_cornerWidth: CGFloat = 3.0  /** 扫描器棱角宽度 */
private let scanner_cornerLength: CGFloat = 20.0    /** 扫描器棱角长度 */
private let scanner_lineHeight: CGFloat = 10.0   /** 扫描器线条高度 */
private let flashlightBtn_width: CGFloat = 20.0  /** 手电筒按钮宽度 */
private let flashlightLab_height: CGFloat = 15.0 /** 手电筒提示文字高度 */
private let tipLab_height: CGFloat = 50.0    /** 扫描器下方提示文字高度 */

private let scannerLineAnmationKey = "ScannerLineAnmationKey" /** 扫描线条动画Key值 */
private var flashlightKey: Void?

class SWScannerView: UIView {
    
    /** 扫描器宽度 */
    var scanner_width: CGFloat!
    /** 扫描器初始x值 */
    var scanner_x: CGFloat!
    /** 扫描器初始y值 */
    var scanner_y: CGFloat!
    
    var config: SWQRCodeCompat!
    private var activityIndicator: UIActivityIndicatorView!
    
    init(frame: CGRect, config: SWQRCodeCompat) {
        super.init(frame: frame)
        
        scanner_width = 0.7*self.frame.size.width
        scanner_x = (self.frame.size.width - scanner_width)/2
        scanner_y = (self.frame.size.height - scanner_width)/2 - 50
        self.config = config
        
        _setupUI()
    }
    
    private func _setupUI() {
        self.backgroundColor = .clear
        
        self.addSubview(self.scannerLine)
        sw_addScannerLineAnimation()
        
        self.addSubview(self.tipLab)
        self.addSubview(self.flashlightBtn)
        self.addSubview(self.flashlightLab)
    }
    
// MARK: - 手电筒点击事件
    @objc private func flashlightClicked(button: UIButton) {
        button.isSelected = !button.isSelected
        sw_setFlashlight(on: button.isSelected)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // 半透明区域
        UIColor(white: 0, alpha: 0.7).setFill()
        UIRectFill(rect)
        
        // 透明区域
        let scanner_rect = CGRect(x: scanner_x, y: scanner_y, width: scanner_width, height: scanner_width)
        UIColor.clear.setFill()
        UIRectFill(scanner_rect)
        
        // 边框
        let borderPath = UIBezierPath(rect: CGRect(x: scanner_x, y: scanner_y, width: scanner_width, height: scanner_width))
        borderPath.lineCapStyle = .round
        borderPath.lineWidth = scanner_borderWidth
        self.config.scannerBorderColor.set()
        borderPath.stroke()
        
        for index in 0...3 {
            let tempPath = UIBezierPath()
            tempPath.lineWidth = scanner_cornerWidth
            self.config.scannerCornerColor.set()
            
            switch index {
                // 左上角棱角
            case 0:
                tempPath.move(to: CGPoint(x: scanner_x + scanner_cornerLength, y: scanner_y))
                tempPath.addLine(to: CGPoint(x: scanner_x, y: scanner_y))
                tempPath.addLine(to: CGPoint(x: scanner_x, y: scanner_y + scanner_cornerLength))
                // 右上角
            case 1:
                tempPath.move(to: CGPoint(x: scanner_x + scanner_width - scanner_cornerLength, y: self.scanner_y))
                tempPath.addLine(to: CGPoint(x: scanner_x + scanner_width, y: scanner_y))
                tempPath.addLine(to: CGPoint(x: scanner_x + scanner_width, y: scanner_y + scanner_cornerLength))
                // 左下角
            case 2:
                tempPath.move(to: CGPoint(x: scanner_x, y: scanner_y + scanner_width - scanner_cornerLength))
                tempPath.addLine(to: CGPoint(x: scanner_x, y: scanner_y + scanner_width))
                tempPath.addLine(to: CGPoint(x: scanner_x + scanner_cornerLength, y: scanner_y + scanner_width))
                // 右下角
            case 3:
                tempPath.move(to: CGPoint(x: scanner_x + scanner_width - scanner_cornerLength, y: scanner_y + scanner_width))
                tempPath.addLine(to: CGPoint(x: scanner_x + scanner_width, y: scanner_y + scanner_width))
                tempPath.addLine(to: CGPoint(x: scanner_x + scanner_width, y: scanner_y + scanner_width - scanner_cornerLength))
            default:
                break
            }
            tempPath.stroke()
        }
    }
    
    /** 扫描线条 */
    private lazy var scannerLine: UIImageView = {
        let tempScannerLine = UIImageView(frame: CGRect(x: scanner_x, y: scanner_y, width: scanner_width, height: scanner_lineHeight))
        tempScannerLine.image = UIImage(named: "SWQRCode.bundle/ScannerLine")
        return tempScannerLine
    }()
    
    /** 扫描器下方提示文字 */
    private lazy var tipLab: UILabel = {
        let tempTipLab = UILabel(frame: CGRect(x: 0, y: scanner_y + scanner_width, width: self.frame.size.width, height: 50))
        tempTipLab.textAlignment = .center
        tempTipLab.textColor = .lightGray
        tempTipLab.font = UIFont.systemFont(ofSize: 12)
        tempTipLab.text = "将二维码/条码放入框内，即可自动扫描"
        return tempTipLab
    }()
    
    /** 手电筒开关 */
    private lazy var flashlightBtn: UIButton = {
        let tempFlashlightBtn = UIButton(type: .custom)
        tempFlashlightBtn.frame = CGRect(x: (self.frame.size.width - flashlightBtn_width)/2, y: scanner_y + scanner_width - 15 - flashlightLab_height - flashlightBtn_width, width: flashlightBtn_width, height: flashlightBtn_width)
        tempFlashlightBtn.isEnabled = false
        tempFlashlightBtn.alpha = 0
        tempFlashlightBtn.addTarget(self, action: #selector(flashlightClicked), for: .touchUpInside)
        tempFlashlightBtn.setBackgroundImage(UIImage(named: "SWQRCode.bundle/Flashlight_Off"), for: .normal)
        tempFlashlightBtn.setBackgroundImage(UIImage(named: "SWQRCode.bundle/Flashlight_On"), for: .selected)
        return tempFlashlightBtn
    }()
    
    /** 手电筒提示文字 */
    private lazy var flashlightLab: UILabel = {
        let tempFlashlightLab = UILabel(frame: CGRect(x: scanner_x, y: scanner_y + scanner_width - 10 - flashlightLab_height, width: scanner_width, height: flashlightLab_height))
        tempFlashlightLab.font = UIFont.systemFont(ofSize: 12)
        tempFlashlightLab.textColor = .white
        tempFlashlightLab.text = "轻触照亮"
        tempFlashlightLab.alpha = 0;
        tempFlashlightLab.textAlignment = .center
        return tempFlashlightLab
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

// MARK: - 扫描线条动画
extension SWScannerView {
    
    /** 添加扫描线条动画 */
    func sw_addScannerLineAnimation() {
        // 若已添加动画，则先移除动画再添加
        self.scannerLine.layer.removeAllAnimations()
        
        let lineAnimation = CABasicAnimation(keyPath: "transform")
        lineAnimation.toValue = NSValue(caTransform3D: CATransform3DMakeTranslation(0, scanner_width - scanner_lineHeight, 1))
        lineAnimation.duration = 4
        lineAnimation.repeatCount = MAXFLOAT
        self.scannerLine.layer.add(lineAnimation, forKey: scannerLineAnmationKey)
        // 重置动画运行速度为1.0
        self.scannerLine.layer.speed = 1.0
    }
    
    /** 暂停扫描器动画 */
    func sw_pauseScannerLineAnimation() {
        // 取出当前时间，转成动画暂停的时间
        let pauseTime = self.scannerLine.layer.convertTime(CACurrentMediaTime(), from: nil)
        // 设置动画的时间偏移量，指定时间偏移量的目的是让动画定格在该时间点的位置
        self.scannerLine.layer.timeOffset = pauseTime
        // 将动画的运行速度设置为0， 默认的运行速度是1.0
        self.scannerLine.layer.speed = 0
    }
}

// MARK: - 显示/隐藏手电筒
extension SWScannerView {
    
    /** 显示手电筒 */
    func sw_showFlashlight(animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.6, animations: {
                self.flashlightLab.alpha = 1.0
                self.flashlightBtn.alpha = 1.0
                self.tipLab.alpha = 0
            }, completion: { (finished) in
                self.flashlightBtn.isEnabled = true
            })
        }
        else {
            self.flashlightLab.alpha = 1.0
            self.flashlightBtn.alpha = 1.0
            self.tipLab.alpha = 0
            self.flashlightBtn.isEnabled = true
        }
    }
    
    /** 隐藏手电筒 */
    func sw_hideFlashlight(animated: Bool) {
        self.flashlightBtn.isEnabled = false
        if animated {
            UIView.animate(withDuration: 0.6, animations: {
                self.flashlightLab.alpha = 0
                self.flashlightBtn.alpha = 0
                self.tipLab.alpha = 1.0
            })
        }
        else {
            self.flashlightLab.alpha = 0
            self.flashlightBtn.alpha = 0
            self.tipLab.alpha = 1.0
        }
    }
}

// MARK: - 添加/移除指示器
extension SWScannerView {
    
    /** 添加指示器 */
    func sw_addActivityIndicator() {
        if self.activityIndicator == nil {
            self.activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: self.config.indicatorViewStyle)
            self.activityIndicator.center = self.center
            self.addSubview(self.activityIndicator)
        }
        self.activityIndicator.startAnimating()
    }
    
    /** 移除指示器 */
    func sw_removeActivityIndicator() {
        if self.activityIndicator != nil {
            self.activityIndicator.removeFromSuperview()
            self.activityIndicator = nil
        }
    }
}

// MARK: - 设置/获取手电筒开关状态
extension SWScannerView {
    
    /** 设置手电筒开关 */
    func sw_setFlashlight(on: Bool) {
        SWQRCodeHelper.sw_flashlight(on: on)
        self.flashlightLab.text = on ? "轻触关闭":"轻触照亮"
        self.flashlightBtn.isSelected = on;
        objc_setAssociatedObject(self, &flashlightKey, on, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    /** 获取手电筒当前开关状态 */
    func sw_setFlashlightOn() -> Bool {
        return objc_getAssociatedObject(self, &flashlightKey) as? Bool ?? false
    }
}





