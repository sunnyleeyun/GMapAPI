//
//  ViewController.swift
//  GMapSwift
//
//  Created by Sunny on 2016/8/26.
//  Copyright © 2016年 Sunny. All rights reserved.
//


import UIKit
import GoogleMaps
import MapKit
import CoreLocation


class ViewController: UIViewController, CLLocationManagerDelegate, UISearchBarDelegate, LocateOnTheMap {
    
    
    var locationManager:CLLocationManager!

    @IBOutlet weak var myMap: MKMapView!
    //@IBOutlet weak var googleMapsContainer: UIView!
    var googleMapsView: GMSMapView!
    //var googleMapsView = GMSMapView.mapWithFrame(CGRectZero, camera: camera)

    @IBAction func searchWithAddress(sender: AnyObject) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.presentViewController(searchController, animated: true, completion: nil)
    }
    var searchResultController: SearchResultsController!
    var resultArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //產生CLLocationManager，並要求授權
        locationManager = CLLocationManager()
        locationManager.requestWhenInUseAuthorization()
        
        //得到座標
        let coordinate = locationManager.location?.coordinate
        print("緯度：\(coordinate?.latitude)")
        print("經度：\(coordinate?.longitude)")

        //直向縮放
        let latDelta:CLLocationDegrees = 0.01
        //橫向縮放
        let lonDelta:CLLocationDegrees = 0.01
        //從直向縮放與橫向縮放產生範圍
        let span:MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        //從座標與縮放範圍產生顯示範圍
        if coordinate != nil{
            let region:MKCoordinateRegion = MKCoordinateRegionMake(coordinate!, span)
            //讓地圖秀出區域
            myMap.setRegion(region, animated: true)
        }
        
        //設定準確度
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        //設定活動模式
        locationManager.activityType = .Fitness
        //設定delegate
        locationManager.delegate = self
        //開始更新位置資訊
        locationManager.startUpdatingLocation()
        
        //設定userTrackingMode
        myMap.userTrackingMode = .FollowWithHeading
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        self.googleMapsView = GMSMapView(frame: self.myMap.frame)
        self.view.addSubview(self.googleMapsView)
        
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let coordinate = locations[0].coordinate //拿到目前座標
        
        print("緯度：\(coordinate.latitude)")
        print("經度：\(coordinate.longitude)")
    }
    
    func locateWithLongitude(lon: Double, andLatitude lat: Double, andTitle title: String) {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let position = CLLocationCoordinate2DMake(lat, lon)
            let marker = GMSMarker(position: position)
            
            let camera = GMSCameraPosition.cameraWithLatitude(lat, longitude: lon, zoom: 10)
            self.googleMapsView.camera = camera
            
            marker.title = "Address: \(title)"
            marker.map = self.googleMapsView
        }
    }
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        let placeClient = GMSPlacesClient()
        placeClient.autocompleteQuery(searchText, bounds: nil, filter: nil){(results, error: NSError?) -> Void in
            
            self.resultArray.removeAll()
            if results == nil{
            return
            }
            for result in results!{
                if let result = result as? GMSAutocompletePrediction{
                    self.resultArray.append(result.attributedFullText.string)
                }
            }
        }
        self.searchResultController.reloadDataWithArray(self.resultArray)
    }
    
}




