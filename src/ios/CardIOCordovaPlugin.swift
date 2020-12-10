import UIKit

@objc(CardIOCordovaPlugin) class CardIOCordovaPlugin : CDVPlugin {


    var window: UIWindow?
    var vc = CardIOScreenTestViewController()


    @objc(scan:)
    func scan(command: CDVInvokedUrlCommand) {
        vc = CardIOScreenTestViewController()
        if command.arguments[8] as! String == "white" {
                vc.colorBackground = "#FFFFFF"
                }else{
                vc.colorBackground = "#1d3664"
                }
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        vc.segmentSelectionAtIndex = {[weak self] (image, number, monthyear, name) in
            
            self!.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            
            let base64String = image.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
            let message = ["cardImage": base64String, "number": number, "monthyear": monthyear, "cardholderName": name] as [AnyHashable: Any];
            
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message);
            self!.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
        }
        vc.backCallBack = {[weak self] in
            self!.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "Back");
            self!.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
        }
    }

    @objc(closeApp:)
    func closeApp(command: CDVInvokedUrlCommand) {
         exit(-1)
    }
}
