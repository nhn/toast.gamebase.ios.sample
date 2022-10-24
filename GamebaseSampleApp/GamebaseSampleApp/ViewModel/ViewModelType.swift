//
//  ViewModelType.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/08/24.
//

import Foundation
import RxSwift

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
