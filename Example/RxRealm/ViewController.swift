
import UIKit

import RxSwift
import RxCocoa

import RealmSwift
import RxRealm

//realm model
class Lap: Object {
    dynamic var time: TimeInterval = Date().timeIntervalSinceReferenceDate
}

//view controller
class ViewController: UIViewController {
    let bag = DisposeBag()
    let realm = try! Realm()
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var deleteLastItemButton: UIBarButtonItem!
    @IBOutlet weak var addTwoItemsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Observable<Results<Lap>> - wrap Results as observable
         */
        Observable.from(realm.objects(Lap.self))
            .map {results in "laps: \(results.count)"}
            .subscribe { event in
                self.title = event.element
            }
            .addDisposableTo(bag)

        /*
         Observable<Array<Lap>> - convert Results to Array and wrap as observable
         */
        Observable.from(realm.objects(Lap.self).sorted(byProperty: "time", ascending: false))
            .map (Array.init)
            .map {array in array.prefix(5) }
            .bindTo(tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, element, cell) in
                cell.textLabel!.text = formatter.string(from: Date(timeIntervalSinceReferenceDate: element.time))
            }
            .addDisposableTo(bag)
        
        /*
         Use bindable sink to add objects
         */
        addTwoItemsButton.rx.tap
            .map { [Lap(), Lap()] }
            .bindTo(Realm.rx.add())
            .addDisposableTo(bag)
        
        /*
         Use bindable sink to delete objects
         */
        deleteLastItemButton.rx.tap
            .map {[unowned self] in self.realm.objects(Lap.self).sorted(byProperty: "time", ascending: false)}
            .filter {$0.count > 0}
            .map { $0.first! }
            .bindTo(Realm.rx.delete())
            .addDisposableTo(bag)
    }
}
