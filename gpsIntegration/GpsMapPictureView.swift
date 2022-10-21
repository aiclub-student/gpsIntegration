//
//  GpsMapPictureView.swift
//  gpsIntegration
//
//  Created by Amit Gupta on 10/1/22.
//
import SwiftUI
import CoreLocationUI
import MapKit

import Alamofire
import SwiftyJSON

struct GpsMapPictureView: View {
    @StateObject var locationManager = LocationManager()
    
    @State var tracking=MapUserTrackingMode.follow
    @State var annotation=MKPointAnnotation()
    
    @State var visibleStatus = "Click on the green button to start"
    @State var visibleLog = " "
    
    @State private var showingImagePicker = false
    @State private var showingMap = true
    @State private var inputImage: UIImage? = UIImage(systemName: "list")
    @State private var showLocationButton = false
    @State private var treeName=""
    @State private var minutesWatering=""
    
    @State private var calculatedET=0.0
    let SQFEET_TO_GALLON=0.623
    let GALLONS_PER_MINUTE = 2.0
    let AVG_SQ_FEET = 600.0
    
    var body: some View {
        HStack {
            VStack {
                
                Button("Upload picture"){
                    self.buttonPressed()
                }
                .padding(.all, 14.0)
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(10)
                
                
                if let inputImage=inputImage {
                    Image(uiImage: inputImage).resizable()
                        .aspectRatio(contentMode: .fit)
                }
                
                if showLocationButton {
                    LocationButton {
                        showingMap = true
                        showLocationButton = false
                        locationManager.requestLocation()
                        // Need to call the next API
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            visibleStatus="Getting watering needs..."
                            callETAPI(treeName)
                            
                        }
      
                        
                    }
                    .frame(height: 44)
                }
                
                if showMap() {
                    Map(coordinateRegion:$locationManager.area, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: [annotation.coordinate]) {_ in
                        MapMarker(coordinate: CLLocationCoordinate2D(latitude: locationManager.location!.latitude, longitude: locationManager.location!.longitude))
                    }
                    
                }

                Spacer()
                Text(visibleStatus)
                //Text(currentStatus())
            }
        }.sheet(isPresented: $showingImagePicker, onDismiss: processImage) {
            ImagePicker(image: self.$inputImage)
        }
    }

    
    func currentStatus() -> String {
        if inputImage != nil && locationManager.location != nil {
            
            let a = "Minutes:\(minutesWatering)\nTree: \(treeName)\n Location: \(locationManager.location ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))\n Log:\(visibleLog)"
            return a
        }
        else {
            return " "
        }
    }
    
    func buttonPressed() {
        print("Button pressed")
        
        self.showingImagePicker = true
        showingMap = false
    }
    
    func processAIResult(_ result:String) {
        print("In processAIResult, with result=\(result)")
        treeName="Apples"
        let kcValue=LoadPlantData.getKc(treeName)
        visibleStatus = "Identified \(treeName), now need Location"
        showLocationButton = true

    }
    
    func processImage() {
        showingImagePicker = false
        visibleStatus="Checking..."
        guard let inputImage = inputImage else {return}
        self.visibleStatus="Calling AI to identify the plant"
        print("Wrong AI: Processing image due to Button press")
        let imageJPG=inputImage.jpegData(compressionQuality: 0.0034)!
        let imageB64 = Data(imageJPG).base64EncodedData()
        let uploadURL="https://askai.aiclub.world/957e82c0-623c-49b3-b867-ae7ed29b9496"
        
        AF.upload(imageB64, to: uploadURL).responseString { response in
            
            //debugPrint(response)
            switch response.result {
            case .success(let responseJsonStr):
                //print("\n\n Success value and JSON: \(responseJsonStr)")
                let myJson = JSON(parseJSON: responseJsonStr)
                let predictedValue = myJson["predicted_label"].string
                print("Saw predicted value \(String(describing: predictedValue))")
                
                let predictionMessage = predictedValue!
                self.visibleStatus=predictionMessage
                processAIResult(predictedValue!)
                processAIResult(predictedValue!)
                
            case .failure(let error):
                print("\n\n Request failed with error: \(error)")
            }
        }
    }
        
        
        func callETAPI(_ plantName:String) {
            print("Called ET API with  plant \(plantName)")
            let api_key="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY2NDU1MjQ0MywianRpIjoiYmUyZmFhZTItNDQ1NS00OWZjLTgyOWUtNTI1MjliMTU5ZWU0IiwibmJmIjoxNjY0NTUyNDQzLCJ0eXBlIjoiYWNjZXNzIiwic3ViIjoiaXFwdGZocU1YRFNRTUJSVGhWYzJHTE5ocVF5MSIsImV4cCI6MTY4MDEwNDQ0Mywicm9sZXMiOiJ1c2VyIiwidXNlcl9pZCI6ImlxcHRmaHFNWERTUU1CUlRoVmMyR0xOaHFReTEifQ.2FLQnEmS8Q1mcm_bH7lDOYBUulG15l40lerMfd-O5DQ"
            
            let urlToCall = "https://openet.dri.edu/raster/timeseries/point"
            var args:[String:String] = [:]
            let headers: HTTPHeaders = [
                         "Authorization": api_key
                    ]

            args["start_date"]="2022-09-21"          // inclusive starting date
            args["end_date"]="2022-09-30"         // inclusive completion date
            let dateFormatter: DateFormatter = {
                    let formatter = DateFormatter()
                    formatter.dateFormat="yyyy-MM-dd"
                    return formatter
                }()
            let startDate=Calendar.current.date(byAdding: .day, value: -10, to: Date())!
            let endDate=Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            args["start_date"]=dateFormatter.string(from: startDate)
            args["end_date"]=dateFormatter.string(from: endDate)
            args["interval"]="daily"           // time interval
            // spatial options
            args["lon"]=String(locationManager.location?.longitude ?? -119.7805)            // longitude of interest
            args["lat"]=String(locationManager.location?.latitude ?? 47.1215)                // latitude of interest
            // OpenEt options
            args["model"]="ensemble"         // model selection (ensemble, geesebal, ssebop, eemetric, sims, disalexi, ptjpl)
            args["variable"]="et"               // variable to retrieve (ndvi, etf, eto, et)
            args["ref_et_source"]="gridmet"          // reference et collection (cimis, gridmet)
            // data processing options
            args["units"]="metric"      // output units (metric [mm], english [in])
            args["output_file_format"]="csv"        // file extension (csv, json)
            
            print("Calling remote ET API with p=\(plantName), args=\(args)")
            AF.request(urlToCall, method: .get, parameters: args, headers:headers ).responseString { response in
                //debugPrint("AF.Response:",response)
                switch response.result {
                case .success(let responseJsonStr):
                    //print("\n\n Success value and JSON: \(responseJsonStr)")
                    let ma=getCSVAvg(responseJsonStr,1)
                    print("MA Is \(ma)")
                    calculatedET=ma
                    let ga=ma*SQFEET_TO_GALLON
                    let displayInfo="MA = \(ma),\n Gallons/sqfeet/month=\(ga)"
                    calculateWateringNeeds()
                case .failure(let error):
                    print("\n\n Request failed with error: \(error)")
                }
            }
        }
        
    func getCSVAvg(_ s:String, _ n:Int) -> Double {
        var sum=0.0
        var count=0
        let sa: [String] = s.components(
            separatedBy: "\n"
        )
        for st in sa {
            let sb:[String]=st.components(separatedBy: ",")
            //print("SB is \(sb)")
            if sb.count<2 {
                continue
            }
            if let l=Double(sb[1].filter { !$0.isWhitespace }) {
                sum+=l
                count+=1
                //print("Saw \(l), now sum is \(sum), count=\(count)")
            }
        }
        let avg=sum/Double(count)
        return avg
        
    }
    
    func calculateWateringNeeds() {
        // Update state variables as needed
        print("****** Calculating watering needs based on ET=\(calculatedET) and Tree=\(treeName)")
        let kcFactor=LoadPlantData.getKc(treeName)
        let minutesPerWeek=calculatedET*kcFactor*SQFEET_TO_GALLON*AVG_SQ_FEET/(GALLONS_PER_MINUTE*30.0/7.0)
        minutesWatering="\(minutesPerWeek)"
        visibleStatus=String(format: "Water \(treeName) for %.0f minutes/week", minutesPerWeek)
        
    }
    
    func showMap() -> Bool {
        //print("Starting showMap")
        if let l = locationManager.location {
            print("Location is \(l) in showMap")
            return showingMap
        }
        
        print("Locaton is Nil in showMap")
        return false
    }
}

struct GpsMapPictureView_Previews: PreviewProvider {
    static var previews: some View {
        GpsMapPictureView()
    }
}

