//
//  ListingProtocols.swift
//  Combine+CoreData+Viper
//
//  Created by Ramkrishna Sharma on 27/03/22.
//

import Foundation
import UIKit

protocol ViewToPresenterProtocol {
    var view: PresenterToViewProtocol? { get set }
    var interactor: PresenterToInteractorProtocol? { get set }
    var router: PresenterToRouterProtocol? { get set }
    func startFetching()
    func addPerson(fullName: String)
    func deletePerson(fullName: String)
    func updatePerson(fullName: String, searchFullName: String)
}

protocol PresenterToViewProtocol {
    func showRecord(records: Array<ListingModel>)
}

protocol PresenterToRouterProtocol {
    static func createModule()-> ViewController
}

protocol PresenterToInteractorProtocol {
    var coreDataStore: CoreDataStoring! { get set }
    var presenter: InteractorToPresenterProtocol? { get set }
    func fetch()
    func addPerson(fullName: String)
    func deletePerson(fullName: String)
    func updatePerson(fullName: String, searchFullName: String)
}

protocol InteractorToPresenterProtocol {
    func fetchedSuccess(listingModelArray: Array<ListingModel>)
}
