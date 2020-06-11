//
//  FilterParams.swift
//  InstaFilter
//
//  Created by yeuchi on 6/4/20.
//  Copyright © 2020 yeuchi. All rights reserved.
//

import Foundation

enum ViewState : String {
    case Source
    case Filtered
}

enum KernelType : String {
     case SobelX
     case SobelY
     case Sharpen
     case Blur
     case Identity
 }

enum EffectLevel : String {
     case Small
     case Large
 }

struct FilterParams {
       
    var kernel:KernelType = KernelType.Identity
    var effectLevel:EffectLevel = EffectLevel.Large
       
    private let identity: [[Int]] = [[0, 0, 0], [0, 1, 0], [0, 0, 0]]
    private let xSobel_small: [[Int]] = [[0, 0, 0], [0, 1, -1], [0, 0, 0]]
    private let xSobel_large: [[Int]] = [[0, 1, -1], [0, 1, -1], [0, 1, -1]]
    private let ySobel_small: [[Int]] = [[0, 0, 0], [0, 1, 0], [0, -1, 0]]
    private let ySobel_large: [[Int]] = [[0, 0, 0], [1, 1, 1], [-1, -1, -1]]
    private let sharpen_small: [[Int]] = [[-1, -1, -1], [-1, 14, -1], [-1, -1, -1]]
    private let sharpen_large: [[Int]] = [[-1, -1, -1], [-1, 10, -1], [-1, -1, -1]]
    private let blur_small: [[Int]] = [[1, 1, 1], [1, 5, 1], [1, 1, 1]]
    private let blur_large: [[Int]] = [[1, 1, 1], [1, 1, 1], [1, 1, 1]]

    func getKernelValues() -> [[Int]] {
        switch(kernel) {
        case KernelType.SobelX:
            return effectLevel == EffectLevel.Small ? xSobel_small : xSobel_large
            
        case KernelType.SobelY:
            return effectLevel == EffectLevel.Small ? ySobel_small : ySobel_large
            
        case KernelType.Sharpen:
            return effectLevel == EffectLevel.Small ? sharpen_small : sharpen_large
            
        case KernelType.Identity:
            return identity
            
        case KernelType.Blur:
            return effectLevel == EffectLevel.Small ? blur_small : blur_large
        }
    }
}
