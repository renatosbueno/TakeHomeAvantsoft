//
//  HomeModuleConfigurator.swift
//  TakeHomeTikTok
//
//  Created by Renato Bueno on 29/03/23.
//

import UIKit

final class HomeModuleConfigurator {
    
    func createModule() -> UIViewController {
        let viewModel = HomeViewModel()
        let view = HomeViewController(viewModel: viewModel)
        viewModel.delegate = view
        
        return view
    }
    
}
