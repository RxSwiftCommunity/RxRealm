
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
    let realm = try! Realm()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addOneItemButton: UIBarButtonItem!
    @IBOutlet weak var addTwoItemsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        //Observable<Results<Lap>>
        let lapCount = realm.objects(Lap).asObservable().map {laps in "\(laps.count) laps"}
        lapCount.subscribeNext {[unowned self]text in
            self.title = text
        }.addDisposableTo(bag)
        
        //Observable<Array<Lap>>
        let laps = realm.objects(Lap).sorted("time", ascending: false).asObservableArray()
        
        laps
        .bindTo(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)) {row, element, cell in
            cell.textLabel!.text = formatter.stringFromDate(NSDate(timeIntervalSinceReferenceDate: element.time))
        }.addDisposableTo(bag)

        
        addOneItemButton.rx_tap
            .map {
                return Lap()
            }
            .bindTo(realm.rx_add())
            .addDisposableTo(bag)
        
        addTwoItemsButton.rx_tap
            .map {
                return [Lap(), Lap()]
            }
            .bindTo(realm.rx_add())
            .addDisposableTo(bag)

    }
}