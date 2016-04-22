
import UIKit
import RealmSwift

let formatter: NSDateFormatter = {
    let f = NSDateFormatter()
    f.timeStyle = .LongStyle
    return f
}()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //reset the realm on each app launch
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }

        return true
    }
    
}