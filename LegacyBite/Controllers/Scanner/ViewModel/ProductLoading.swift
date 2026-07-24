//
//  ProductLoading.swift
//  LegacyBite
//
//  Created by Grizly on 23.07.26.
//

import Foundation

protocol ProductLoading {
    func loadProduct(
        barCode:String,
        completion: @escaping (Result<SSProductObject, NSError>)->Void
    )
}
