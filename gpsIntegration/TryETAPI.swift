//
//  TryETAPI.swift
//  gpsIntegration
//
//  Created by Amit Gupta on 10/14/22.
//

import SwiftUI
import Alamofire
import SwiftyJSON

struct TryETAPI: View {
    @State var calculatedET=0.0
    @State var displayInfo="<waiting>"
    @State var startDate=Calendar.current.date(byAdding: .day, value: -10, to: Date())!
    @State var endDate=Calendar.current.date(byAdding: .day, value: -3, to: Date())!
    
    
    let SQFEET_TO_GALLON=0.623
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Spacer()

            Text("ET API Test")
                .font(.system(size:40))

            DatePicker("Start date",selection: $startDate, displayedComponents: .date)
            DatePicker("End date",selection: $endDate, displayedComponents: .date)
             
            Button("Check"){
                self.callETAPI("ABC")
            }
            .font(.system(size:20))
            .padding(.all, 14.0)
            .foregroundColor(.white)
            .background(Color.red)
        .cornerRadius(10)
            Spacer()

            Text(displayInfo)
                .font(.system(size:30))
                .foregroundColor(.white)
                .background(Color.green)
                .cornerRadius(10)
            Spacer()

        }

            
    }
    
    let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat="yyyy-MM-dd"
            return formatter
        }()
    
    func callETAPI(_ plantName:String) {
        print("Called ET API with  plant \(plantName), start=\(startDate), end=\(endDate)")
        let api_key="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJmcmVzaCI6ZmFsc2UsImlhdCI6MTY2NDU1MjQ0MywianRpIjoiYmUyZmFhZTItNDQ1NS00OWZjLTgyOWUtNTI1MjliMTU5ZWU0IiwibmJmIjoxNjY0NTUyNDQzLCJ0eXBlIjoiYWNjZXNzIiwic3ViIjoiaXFwdGZocU1YRFNRTUJSVGhWYzJHTE5ocVF5MSIsImV4cCI6MTY4MDEwNDQ0Mywicm9sZXMiOiJ1c2VyIiwidXNlcl9pZCI6ImlxcHRmaHFNWERTUU1CUlRoVmMyR0xOaHFReTEifQ.2FLQnEmS8Q1mcm_bH7lDOYBUulG15l40lerMfd-O5DQ"
        print("Calling ET API with p=\(plantName)")
        let urlToCall = "https://openet.dri.edu/raster/timeseries/point"
        var args:[String:String] = [:]
        let headers: HTTPHeaders = [
                     "Authorization": api_key
                ]

        args["start_date"]="2022-09-21"          // inclusive starting date
        args["end_date"]="2022-09-30"         // inclusive completion date
        args["start_date"]=dateFormatter.string(from: startDate)
        args["end_date"]=dateFormatter.string(from: endDate)
        args["interval"]="daily"           // time interval
        // spatial options
        args["lon"]="-119.78058815"              // longitude of interest
        args["lat"]="47.12151217"               // latitude of interest
        // OpenEt options
        args["model"]="ensemble"         // model selection (ensemble, geesebal, ssebop, eemetric, sims, disalexi, ptjpl)
        args["variable"]="et"               // variable to retrieve (ndvi, etf, eto, et)
        args["ref_et_source"]="gridmet"          // reference et collection (cimis, gridmet)
        // data processing options
        args["units"]="metric"      // output units (metric [mm], english [in])
        args["output_file_format"]="csv"        // file extension (csv, json)
        print("Args are: \(args)")
        
        AF.request(urlToCall, method: .get, parameters: args, headers:headers ).responseString { response in
            debugPrint("AF.Response:",response)
            switch response.result {
            case .success(let responseJsonStr):
                print("\n\n Success value and JSON: \(responseJsonStr)")
                let ma=getCSVAvg(responseJsonStr,1)
                print("MA Is \(ma)")
                calculatedET=ma
                let ga=ma*SQFEET_TO_GALLON
                let ma2f=String(format:"%.2f",ma)
                let ga2f=String(format:"%.2f",ga)
                displayInfo="MA = \(ma2f), Gallons/sqfeet/month=\(ga2f), Start=\(startDate), End=\(endDate)"
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
        
        // requests.post(url=url, data=json.dumps(args), headers=header, verify=True)
}

struct TryETAPI_Previews: PreviewProvider {
    static var previews: some View {
        TryETAPI()
    }
}
