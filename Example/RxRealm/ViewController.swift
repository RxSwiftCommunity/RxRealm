
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
        
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let realm = try! Realm()

        //Observable<Results<Lap>>
        let lapCount = realm.objects(Lap).asObservable().map {laps in "\(laps.count) laps"}
        lapCount.subscribeNext {[unowned self]text in
            self.title = text
        }.addDisposableTo(bag)
        
        //Observable<Array<Lap>>
        let laps = realm.objects(Lap).sorted("time", ascending: false).asObservableArray()
        
        laps.map {array in
            return array.prefix(3) //get array slice of last 3 items
        }
        .bindTo(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)) {row, element, cell in
            cell.textLabel!.text = formatter.stringFromDate(NSDate(timeIntervalSinceReferenceDate: element.time))
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