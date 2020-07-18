

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
            
            print("image:",image)
            print("number:",number)
            print("monthyear:",monthyear)
            print("name:",name)
            
            self!.window = UIWindow(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
            
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "The plugin succeeded");
            self!.commandDelegate!.send(pluginResult, callbackId: command.callbackId);
        }
        
    }
    
}
