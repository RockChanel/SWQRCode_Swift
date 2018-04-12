# SWQRCode_Swift

![image](https://github.com/RockChanel/SWGIF/blob/master/SWQRCode.gif)

简书地址：[iOS 高仿微信扫一扫](https://www.jianshu.com/p/1fc34089adf5)

Objective - C版本地址：[SWQRCode oc 版本](https://github.com/RockChanel/SWQRCode_Objc)

`SWQRCode_Swift` 为 `SWQRCode` swift 版本，高仿微信扫一扫功能，包括`二维码/条码识别、相册图片二维码/条码识别、手电筒功能`等，请使用真机进行测试。

`SWQRCode_Swift` 舍弃了 `Timer` 而采用 `CABasicAnimation` 实现扫一扫动画效果。

若需在项目中使用，只需将 `SWQRCode` 文件夹拖入项目中，并在 `info.plist` 中添加 `Privacy - Photo Library Usage Description` 以及 `Privacy - Camera Usage Description` 配置，声明相机相册权限。
 
`SWQRCode_Swift` 主要 API :

    // MARK: - 恢复/暂停扫一扫功能
    extension SWQRCodeViewController {
        
        /// 恢复扫一扫功能
        private func _resumeScanning() {
            self.session.startRunning()
            self.scannerView.sw_addScannerLineAnimation()
        }
        
        /// 暂停扫一扫功能
        private func _pauseScanning() {
            self.session.stopRunning()
            self.scannerView.sw_pauseScannerLineAnimation()
        }
    }


