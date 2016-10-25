
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

    var laps: Results<Lap>!

    override func viewDidLoad() {
        super.viewDidLoad()

        laps = realm.objects(Lap.self).sorted(byProperty: "time", ascending: false)

        /*
         Observable<Results<Lap>> - wrap Results as observable
         */
        Observable.from(laps)
            .map {results in "laps: \(results.count)"}
            .subscribe { event in
                self.title = event.element
            }
            .addDisposableTo(bag)

        /*
         Observable<Results<Lap>> - reacting to change sets
         */
        Observable.changesetFrom(laps)
            .subscribe(onNext: {[unowned self] results, changes in
                if let changes = changes {
                    self.tableView.applyChangeset(changes)
                } else {
                    self.tableView.reloadData()
                }
            })
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

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return laps.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let lap = laps[indexPath.row]

        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        cell.textLabel?.text = formatter.string(from: Date(timeIntervalSinceReferenceDate: lap.time))
        return cell
    }
}

extension UITableView {
    func applyChangeset(_ changes: RealmChangeset) {
        beginUpdates()
        insertRows(at: changes.inserted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        reloadRows(at: changes.updated.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        deleteRows(at: changes.deleted.map { IndexPath(row: $0, section: 0) }, with: .automatic)
        endUpdates()
    }
}
