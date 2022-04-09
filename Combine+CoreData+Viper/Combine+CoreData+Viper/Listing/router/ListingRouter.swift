//
//  ListingRouter.swift
//  Combine+CoreData+Viper
//
//  Created by Ramkrishna Sharma on 27/03/22.
//

import Foundation
import UIKit

class ListingRouter: PresenterToRouterProtocol {
    static func createModule() -> ViewController {
        let view = mainstoryboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        var presenter: ViewToPresenterProtocol & InteractorToPresenterProtocol = ListingPresenter()
        var interactor: PresenterToInteractorProtocol = ListingInteractor()
        let router: PresenterToRouterProtocol = ListingRouter()
        view.presentor = presenter
        presenter.view = view
        presenter.router = router
        presenter.interactor = interactor
        interactor.presenter = presenter
        interactor.coreDataStore = CoreDataStore.default
        return view
    }

    static var mainstoryboard: UIStoryboard{
        return UIStoryboard(name:"Main",bundle: Bundle.main)
    }
}
