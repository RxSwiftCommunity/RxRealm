
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
        
        /*
         Observable<Results<Lap>> - wrap Results as observable
         */
        realm.objects(Lap).asObservable()
            .map {laps in "\(laps.count) laps"}
            .subscribeNext {[unowned self]text in
                self.title = text
            }
            .addDisposableTo(bag)
        
        /* 
         Observable<Array<Lap>> - convert Results to Array and wrap as observable
         */
        realm.objects(Lap).sorted("time", ascending: false).asObservableArray()
            .map {array in array.prefix(5) }
            .bindTo(tableView.rx_itemsWithCellIdentifier("Cell", cellType: UITableViewCell.self)) {row, element, cell in
                cell.textLabel!.text = formatter.stringFromDate(NSDate(timeIntervalSinceReferenceDate: element.time))
            }.addDisposableTo(bag)

        /*
         Use bindable sinks to add objects
         */
        addOneItemButton.rx_tap
            .map { Lap() }
            .bindTo(Realm.rx_add())
            .addDisposableTo(bag)
        
        addTwoItemsButton.rx_tap
            .map { [Lap(), Lap()] }
            .bindTo(Realm.rx_add())
            .addDisposableTo(bag)
    }
}