//
//  ViewController.swift
//  MyBTCentral
//
//  Created by KaiChieh on 2018/4/13.
//  Copyright © 2018 KaiChieh. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController {

    let strService = "8B3A14A0-BD8D-4891-98C6-C3CE6B28081B" // get form uuidgen command
    let strCharacteristic1 = "51D39CEA-041D-47D2-979F-B65E0FAC3743"  // for send message
    let strCharacteristic2 = "157012B5-5F47-4D48-8B09-E9EDD519E948"  // for written

    var centralManager: CBCentralManager!
    var foundedService: CBService!
    var ctWriteable: CBCharacteristic!

    @IBOutlet weak var textInfo: UITextView!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var switchStatus: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}
extension ViewController: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch centralManager.state {
        case .poweredOn:
            textInfo.text = "powerOn"
        case .poweredOff:
            textInfo.text = "powerOff"
            return
        default:
            textInfo.text = "unknow"
            return
        }
        centralManager.scanForPeripherals(withServices: [CBUUID(string: strService)], options: nil) // 限定UUID
    }
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        textInfo.text = textInfo.text + "\n \(peripheral.name!), \(RSSI.intValue)"
    }



}

