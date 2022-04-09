//
//  ListingPresenter.swift
//  Combine+CoreData+Viper
//
//  Created by Ramkrishna Sharma on 27/03/22.
//

import Foundation
import UIKit

class ListingPresenter: ViewToPresenterProtocol {
    var view: PresenterToViewProtocol?
    var interactor: PresenterToInteractorProtocol?
    var router: PresenterToRouterProtocol?

    func startFetching() {
        interactor?.fetch()
    }

    func addPerson(fullName: String) {
        interactor?.addPerson(fullName: fullName)
    }

    func deletePerson(fullName: String) {
        interactor?.deletePerson(fullName: fullName)
    }

    func updatePerson(fullName: String, searchFullName: String) {
        interactor?.updatePerson(fullName: fullName, searchFullName: searchFullName)
    }
}

extension ListingPresenter: InteractorToPresenterProtocol {
    func fetchedSuccess(listingModelArray: Array<ListingModel>) {
        view?.showRecord(records: listingModelArray)
    }
}
