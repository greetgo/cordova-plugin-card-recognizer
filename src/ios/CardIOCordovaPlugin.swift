
import UIKit

@objc(CardIOCordovaPlugin) class CardIOCordovaPlugin : CDVPlugin {


    var window: UIWindow?
    var vc = CardIOScreenTestViewController()


    @objc(scan:)
    func scan(command: CDVInvokedUrlCommand) {
        vc = CardIOScreenTestViewController()
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = vc
        window?.makeKeyAndVisible()
        
        vc.segmentSelectionAtIndex = {[weak self] (image, number, monthyear, name) in
                    
            print("image:", image.count)
            print("number:", number)
            print("monthyear:", monthyear)
            print("name:", name)
            
            self!.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            
//            let dataMutable: NSMutableData = NSMutableData()
//            dataMutable.append(image as Data)
//            dataMutable.append(number.data(using: .utf8)!)
//            dataMutable.append(monthyear.data(using: .utf8)!)
//            dataMutable.append(name.data(using: .utf8)!)
            
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsArrayBuffer: image as Data);
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
