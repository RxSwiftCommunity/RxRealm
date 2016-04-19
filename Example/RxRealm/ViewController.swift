
import UIKit

import RxSwift
import RxCocoa

import RealmSwift
import RxRealm

//realm model
class Lap: Object {
    dynamic var time: NSTimeInterval = NSDate().timeIntervalSinceReferenceDate
}

//view controller
class ViewController: UIViewController {
    let bag = DisposeBag()
    let formatter: NSDateFormatter = {
        let f = NSDateFormatter()
        f.timeStyle = .LongStyle
        return f
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //reset realm
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
        
        //results as observable
        let laps = realm.objects(Lap).sorted("time", ascending: false).asObservable()

        //bind to table
        laps.bindTo(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)) {[weak self] row, element, cell in
            cell.textLabel!.text = self!.formatter.stringFromDate(NSDate(timeIntervalSinceReferenceDate: element.time))
        }.addDisposableTo(bag)

        //start adding laps
        addLap()
    }
    
    func addLap() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(Lap())
        }

        performSelector(#selector(addLap), withObject: nil, afterDelay: Double(arc4random_uniform(3) + 2))
    }
}