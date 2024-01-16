/*
 iseebeacons
 
 MIT License

 Copyright (c) 2024 iAchieved.it LLC

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

*/


import Foundation
import CoreLocation
import CoreBluetooth
import UserNotifications
import UserNotificationsUI
import os

class BeaconManager: NSObject, ObservableObject, CLLocationManagerDelegate {
  var locationManager: CLLocationManager?

  @Published var beaconAvailable = false

  override init() {
    super.init()
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    locationManager?.requestAlwaysAuthorization()
  }
  
  func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    if status == .authorizedAlways || status == .authorizedWhenInUse {
      if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
        os_log("Beacon region monitoring available")
        startMonitoring()
      } else {
        os_log("Beacon region monitoring not available")
      }
    } else {
      os_log("Location not authorized")
    }
  }
      
  func startMonitoring() {
    os_log("startMonitoring")
    
    let proximityUUID = UUID(uuidString:"bf707dd7-a3c3-4a4b-b98b-88c175b7d730")
    let beaconID = "com.example.myBeaconRegion" // Unclear whether this needs to be set to anything meaningful
    let region = CLBeaconRegion(proximityUUID: proximityUUID!, identifier: beaconID)
    locationManager!.startMonitoring(for: region)
  }

  func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
    
      if region is CLBeaconRegion {
        os_log("didEnterRegion")
        beaconAvailable=true
        
        let content = UNMutableNotificationContent()
        content.title = "Beacon Detected"
        content.body = "There's a beacon here."
        content.categoryIdentifier = "alarm"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
      }
  }

  func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    if region is CLBeaconRegion {
      os_log("didExitRegion")
      beaconAvailable = false
    }
  }
  
  /*

  func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
      if peripheral.state == .poweredOn {
        os_log("bluetooth on")
      } else {
        os_log("no bluetooth")
      }
  } */
}
