//
//  SlotMachineDataSource.swift
//  SlotMachine
//
//  Created by a1pamys on 9/23/19.
//  Copyright © 2019 Алпамыс. All rights reserved.
//

import UIKit

protocol SlotMachineDataSource {
    var numberOfSlots: Int { get }
    var slotItems: Array<UIImage?> { get }
}
