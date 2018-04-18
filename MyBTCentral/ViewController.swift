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
    var foundedPeripheral: CBPeripheral!
    var ctWriteable: CBCharacteristic!

    @IBOutlet weak var textInfo: UITextView!
    @IBOutlet weak var lblNumber: UILabel!
    @IBOutlet weak var switchStatus: UISwitch!

    @IBAction func switchValueChange(_ sender: UISwitch) {
        let writeDate: Data!
        if sender.isOn {
            writeDate = "ON".data(using: .utf8)
        } else {
            writeDate = "OFF".data(using: .utf8)
        }
        foundedPeripheral.writeValue(writeDate, for: ctWriteable, type: .withResponse)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let globalQueue = DispatchQueue.global(qos: .default)
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
    // didDiscover
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        textInfo.text = textInfo.text + "\n \(peripheral.name!), \(RSSI.intValue)"
        foundedPeripheral = peripheral
        peripheral.delegate = self

        // connected to discoverd device
        centralManager.connect(foundedPeripheral, options: nil)
    }
    // didConnect
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        let uuidService = CBUUID(string: strService)
        // disconverServices
        peripheral.discoverServices([uuidService])
    }

}
extension ViewController: CBPeripheralDelegate {
    // didDiscoverServices
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            print("found error didDisCoverServices")
            return
        }
        if let services = peripheral.services{
            for service in services {
                if service.uuid.uuidString == strService {
                    textInfo.text = textInfo.text + "\n found \(strService)"
                    self.view.backgroundColor = UIColor.green
                    // discoverCharacteristics
                    peripheral.discoverCharacteristics(nil, for: service)
                }
            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            print("found error didDiscoverCharacteristicsFor")
            return
        }
        if let chara = service.characteristics {
            for characteristic in chara {
                if characteristic.uuid.uuidString == strCharacteristic1 {
                    textInfo.text = textInfo.text + "\n found characteristic1 \(strCharacteristic1)"
                    peripheral.setNotifyValue(true, for: characteristic)
                }
                if characteristic.uuid.uuidString == strCharacteristic2 {
                    textInfo.text = textInfo.text + "\n found characteristic2 \(strCharacteristic2)"
                    ctWriteable = characteristic
                }

            }
        }
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print("found error didUpdateValueFor")
            return
        }
        let strData = String(data: characteristic.value!, encoding: .utf8)
        DispatchQueue.main.async {
            self.lblNumber.text = strData
        }
    }

}

