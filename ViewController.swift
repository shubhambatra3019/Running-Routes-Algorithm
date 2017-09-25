//
//  ViewController.swift
//  routeAlgorithm
//
//  Created by Shubham Batra on 23/07/17.
//

import UIKit
import Mapbox
import MapboxDirections
import CoreLocation
import MapboxNavigation
import MapboxGeocoder

class ViewController: UIViewController, MGLMapViewDelegate, UIGestureRecognizerDelegate, CLLocationManagerDelegate {
    
              //Mark: Variables
    var timer:Timer? = nil;
    @IBOutlet weak var distanceShower: UILabel!
    let geocoder = Geocoder(accessToken: "your accessToken")
    @IBOutlet weak var address: UITextField!
    

    
    let directions = Directions(accessToken: "your accessToken")
    @IBOutlet weak var totalDistance: UILabel!
   
    var stepCoordinates:[CLLocationCoordinate2D] = []
    var distance: Double = 0.0
    var locationManager = CLLocationManager()
    var annotationArray: [MGLPointAnnotation] = []
    var count = 0
    var routeLineArray: [MGLPolyline] = []
    var mapView = MGLMapView()
        var waypoints: [CLLocationCoordinate2D] = []
    var location: [CLLocationCoordinate2D] = []
    var dist = 0.0
    var i = 0
    var d = 0
    var farthest = 0.0
    var landmark: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 28.568184, longitude: 77.229252)

    
    //Mark: ViewDidLoad
    
    
    override func viewDidLoad()
    {
        
        super.viewDidLoad()
        
    
        
        
        //Mark: Location Manager
        
        
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
 
        //Mark: Mapbox MapView
                
        let url = URL(string: "mapbox://styles/mapbox/outdoors-v10")
        mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
       // mapView.setCenter(CLLocationCoordinate2D(latitude: 28.568484, longitude: 77.229424), zoomLevel: 15, animated: false)
          mapView.setCenter(CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!), zoomLevel: 15, animated: false)
        
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.showsUserLocation = true
        
        //Mark: Tap Gesture Recognizer
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(action))
        mapView.addGestureRecognizer(tap)
        
        //Mark: Labels 
        view.bringSubview(toFront: address)
        view.bringSubview(toFront: totalDistance)
        view.bringSubview(toFront: distanceShower)
        
   
    }
    
   //Mark: Action for tap Gesture
    
    func action(gestureRecognizer: UIGestureRecognizer)
    {
    //MARK: Annotations
        
    
        let userLoc =  CLLocationCoordinate2D(latitude: (self.mapView.userLocation?.coordinate.latitude)!, longitude:(self.mapView.userLocation?.coordinate.longitude)!)
        waypoints.append(userLoc)
       /* let loca = CLLocation(latitude: userLoc.latitude, longitude: userLoc.longitude)
        
        getLandmark(loca: loca) { (result) in
        
            
            print(self.annotationArray.count)
           self.automationLandmark(completion: { (result) in
               
            })
        }*/
        
        
       let touchPoint = gestureRecognizer.location(in: self.mapView)
        let newLocation: CLLocationCoordinate2D = mapView.convert(touchPoint, toCoordinateFrom: self.mapView)
        let ann = MGLPointAnnotation()
        ann.coordinate = newLocation
        mapView.addAnnotation(ann)
        annotationArray.append(ann)
        
        //Mark: When first Annotation is added
        
        if(count==0)
        {
            
             let userLoc =  CLLocationCoordinate2D(latitude: (self.mapView.userLocation?.coordinate.latitude)!, longitude:(self.mapView.userLocation?.coordinate.longitude)!)
            let endPoint = CLLocationCoordinate2D(latitude: annotationArray[0].coordinate.latitude, longitude: annotationArray[0].coordinate.longitude)
            waypoints.append(userLoc)
            waypoints.append(endPoint)
     
        }

        if(count>0) {
            for i in 0..<routeLineArray.count
            {
                mapView.removeAnnotation(routeLineArray[i])
            }
            distance = 0.0
            
            let newAnnotation = CLLocationCoordinate2D(latitude: annotationArray[count].coordinate.latitude, longitude: annotationArray[count].coordinate.longitude)
            
            waypoints.insert(newAnnotation, at: count)
        }
            getDirections(waypoints: waypoints) { (result: String) in
            //print(self.distance)
        self.automation()
            }
        // self.automation()
        count = count+1
 
 
    }

    
    
    //Mark: Directions
    
    func automationLandmark(completion: (String) -> Void){
      
        
        if(d < annotationArray.count) {
        let locat = CLLocationCoordinate2D(latitude: annotationArray[d].coordinate.latitude, longitude: annotationArray[d].coordinate.longitude)
        waypoints.append(locat)
       
        getDirections(waypoints: waypoints) { (result) in
            if(self.distance > self.farthest) {
                self.farthest = self.distance
                print(self.distance)
                self.landmark = locat
                self.waypoints.remove(at: self.waypoints.count-1)
                self.d = self.d+1
                self.automationLandmark(completion: { (result) in

                })
               
            }
            
            else {
                 self.waypoints.remove(at: self.waypoints.count-1)
                self.d = self.d+1
                self.automationLandmark(completion: { (result) in
                    
                })

            }
            }
        

           
        }
        else {
            
           for i in 0..<annotationArray.count {
                mapView.removeAnnotation(annotationArray[i])
            }
            routeLineArray.removeAll()
    
        annotationArray.removeAll()
        
        let ann = MGLPointAnnotation()
     ann.coordinate = landmark
        mapView.addAnnotation(ann)
            waypoints.append(landmark)
            getDirections(waypoints: waypoints, completion: { (result) in
                
            })
          //  var land: CLLocation = CLLocation(latitude: landmark.latitude, longitude: landmark.longitude)
            //getLandmark(loca: land, completion: { (result) in
                
            //})
            
            
        }
            
        
        print("Hi")
    }
    func automation() {
      
        print("Hi")
       /*      for i in 0..<annotationArray.count {
        mapView.removeAnnotation(annotationArray[i])
        }
        annotationArray.removeAll()
        
        let ann = MGLPointAnnotation()
        ann.coordinate = landmark
        mapView.addAnnotation(ann)
       */
 
      /*  annotationArray.append(ann)
        let loc = CLLocation(latitude: self.annotationArray[i].coordinate.latitude, longitude: self.annotationArray[i].coordinate.longitude)
        
        let options = ReverseGeocodeOptions(location: loc)
        options.allowedScopes = .landmark
        options.maximumResultCount = 50
        let task = geocoder.geocode(options) { (placemarks, attribution, error) in
            print(placemarks?.count)
            for placemark in (placemarks)! {
                
                let anno = MGLPointAnnotation()
                anno.coordinate = CLLocationCoordinate2D(latitude: placemark.location.coordinate.latitude, longitude: placemark.location.coordinate.longitude)
                self.mapView.addAnnotation(anno)
                self.annotationArray.append(anno)
        }*/
            
        
    
    
        
        
        print("Hello")
            let lat:CLLocationDegrees = stepCoordinates[i].latitude+0.00004
            let lon:CLLocationDegrees = stepCoordinates[i].longitude-0.00004
            let loc = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        
            let ann = MGLPointAnnotation()
            ann.coordinate = loc
            mapView.addAnnotation(ann)
            annotationArray.append(ann)
            waypoints.insert(loc, at: self.waypoints.count-1)
            self.dist = self.distance
               getDirections(waypoints: waypoints) { (result) in
            
            
           if(self.dist > self.distance-2) {
                self.i = self.i+1
                print("Hi")
                self.waypoints.remove(at: self.waypoints.count-2)
                self.mapView.removeAnnotation(self.annotationArray[self.annotationArray.count-1])
                self.automation()
                // print(self.stepCoordinates.count)
            }
            else if(self.distance > self.dist && self.distance < 800) {
            print(self.distance)
                print(self.dist)
                
                  self.i = self.i+1
                print("Do")
                             self.automation()
                
            }
            else if(self.distance > 800 ) {
                self.getDirections(waypoints: self.waypoints, completion: { (result) in
                    return
                })
            }
                
               }
    
    
    }
        
 
        
        
        //       if(self.distance < 1200) {
      //  getDirections(waypoints: waypoints) { (result) in
      //      self.automation()
    //   }
    
            //print(waypoints.count)
            //print(distanceShower.text!)
           // getDirections(waypoints: waypoints)
       // }
 
    
    
    
    
        
        
    
    

    func distanceCalculator(waypoints: [CLLocationCoordinate2D], completion:
        (Double) -> Void) {
        
        let directions = Directions.shared
        let options = RouteOptions(coordinates: waypoints, profileIdentifier: .cycling)
        options.allowsUTurnAtWaypoint = false
        
        let task = directions.calculate(options) { (waypoint, routes, error) in
         
            guard error == nil
            else
            {
                print("Error calculating directions: \(error!)")
                return
            }
            
            // print(routes?.first!)
            
            if let route = routes?.first, let leg = route.legs.first
            {                //print("Route via \(leg):")
                let distanceFormatter = LengthFormatter()
                let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
                self.distance = route.distance
              //  print(self.distance)
                          }
            
}
    //task.resume()
        
    }
    
    func getDirections(waypoints: [CLLocationCoordinate2D], completion: @escaping (String) -> Void) {
    
    for i in 0..<self.routeLineArray.count
    {
        self.mapView.removeAnnotation(self.routeLineArray[i])
    }
    self.distance = 0.0
    
            let directions = Directions.shared
        let options = RouteOptions(coordinates: waypoints, profileIdentifier: .walking)
    options.includesSteps = true
                options.includesAlternativeRoutes = true
        options.allowsUTurnAtWaypoint = false
    
        let task = directions.calculate(options)
        { (waypoints, routes, error) in
            //self.stepCoordinates.removeAll()
            guard error == nil else
            {
                print("Error calculating directions: \(error!)")
                return
            }
            
      
            
            if let route = routes?.first
            {
                
               
                             let distanceFormatter = LengthFormatter()
                let formattedDistance = distanceFormatter.string(fromMeters: route.distance)
                let travelTimeFormatter = DateComponentsFormatter()
                travelTimeFormatter.unitsStyle = .short
                let formattedTravelTime = travelTimeFormatter.string(from: route.expectedTravelTime)
               // print("Distance: \(formattedDistance); ETA: \(formattedTravelTime!)")
                self.stepCoordinates.removeAll()
            
             //   print(route.legs.count)
                 for leg in route.legs {
                for step in leg.steps
                
                {
                    if((step.coordinates?.count)!>1) {
                
                    for i in 1..<step.coordinates!.count {
                        
                        self.stepCoordinates.append((step.coordinates?[i])!)
                        
                    }
                    let formattedDistance = distanceFormatter.string(fromMeters: step.distance)
                 
                    
                    
                }
                    }
                }
                if route.coordinateCount > 0
                {
                    
                      // Convert the route’s coordinates into a polyline.
                    var routeCoordinates = route.coordinates!
                    let routeLine = MGLPolyline(coordinates: &routeCoordinates, count: route.coordinateCount)
                    
                    self.routeLineArray.append(routeLine)
                    // Add the polyline to the map and fit the viewport to the polyline.
                    self.mapView.addAnnotation(routeLine)
                    self.mapView.setVisibleCoordinates(&routeCoordinates, count: route.coordinateCount, edgePadding: .zero , animated: false)
                    
                    //self.mapView.setCenter(CLLocationCoordinate2D(latitude: 28.568484, longitude: 77.229424), zoomLevel: 12, animated: false)

                   self.distance = self.distance + route.distance
                  // self.distanceShower.text = "\(self.distance/1000)"
                    //print(self.distance)
                   // print(self.distanceShower.text!)
                  //  self.dist = self.distance/1000
                     completion("We finished")
                }
               // let viewController = NavigationViewController(for: route)
                
                //self.present(viewController, animated: true, completion: nil)
            }
            
        }
  
  //  return self.stepCoordinates
        }
    
    func getLandmark(loca: CLLocation, completion: @escaping (String) -> Void) {
      
        
        let options = ReverseGeocodeOptions(location: loca)
        options.allowedScopes = .landmark
        
        options.maximumResultCount = 50
        let task = geocoder.geocode(options) { (placemarks, attribution, error) in
          //print(placemarks?.count)
            for placemark in (placemarks)! {
                
             let anno = MGLPointAnnotation()
            anno.coordinate = CLLocationCoordinate2D(latitude: placemark.location.coordinate.latitude, longitude: placemark.location.coordinate.longitude)
            self.mapView.addAnnotation(anno)
                self.annotationArray.append(anno)
                
            }; completion("We finished")

        }
       /* let options = ForwardGeocodeOptions(query: "")
        options.focalLocation = loca
        options.allowedScopes = .pointOfInterest
        options.maximumResultCount = 30
        
        let task = geocoder.geocode(options) { (placemarksByQuery, attributionsByQuery, error) in
            
            for placemarkByQuery in placemarksByQuery! {
                
            
            let nearestSkyline = placemarkByQuery.location
                       let distanceToSkyline = nearestSkyline.distance(from: loca)
           //let nearestGoldStar = placemarksByQuery[1][0].location
            //let distanceToGoldStar = nearestGoldStar.distance(from: loca)
            
                
                
                let distance = LengthFormatter().string(fromValue: distanceToSkyline, unit: LengthFormatter.Unit.meter)
            
                
                if(distanceToSkyline < 800 && distanceToSkyline > 200) {
                    let anno = MGLPointAnnotation()
                    anno.coordinate = CLLocationCoordinate2D(latitude: placemarkByQuery.location.coordinate.latitude, longitude: placemarkByQuery.location.coordinate.longitude)
                    self.mapView.addAnnotation(anno)

            print("Found a chili parlor \(distance) away.")
                }
                else{
                    print("Hi")
                }
            }
            }*/
    }
    
    
    
    //Mark: Clear the map
    @IBAction func clear(_ sender: UIBarButtonItem) {
    waypoints.removeAll()
    self.i = 0
    self.d = 0
        stepCoordinates.removeAll()
        
    for i in 0..<routeLineArray.count
    {
    mapView.removeAnnotation(routeLineArray[i])
    }
    waypoints.removeAll()
    routeLineArray.removeAll()
    mapView.removeAnnotations(annotationArray)
    count = 0
    annotationArray.removeAll()
    print(annotationArray.count)
   // distanceShower.text = "0.0"
    distance = 0.0
        mapView.setCenter(CLLocationCoordinate2D(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!), zoomLevel: 15, animated: false)

        
    }
    
    
    
   /* func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let temp = mapView.userLocation!
        let loc = CLLocationCoordinate2D(latitude: temp.coordinate.latitude, longitude: temp.coordinate.longitude)
        location.append(loc)
        if (location.count==5) {
            let path = MGLPolyline(coordinates: &location, count: 5)
            mapView.addAnnotation(path)
             self.mapView.setVisibleCoordinates(&location, count: 5, edgePadding: .zero , animated: false)
        }
        
    }
    */
    
     
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}
