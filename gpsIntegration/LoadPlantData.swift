//
//  LoadPlantData.swift
//  gpsIntegration
//
//  Created by Amit Gupta on 10/14/22.
//

import Foundation

class LoadPlantData {
    
    static var plantList:[String:Double] = [:]
    
    static func initialize() {
        if let filepath = Bundle.main.path(forResource: "PlantKcValues", ofType: "csv") {
            do {
                let contents = try String(contentsOfFile: filepath)
                //print(contents)
                let sa: [String] = contents.components(
                    separatedBy: "\n"
                )
                for st in sa {
                    let sb:[String]=st.components(separatedBy: ",")
                    //print("SB is \(sb)")
                    if sb.count<2 {
                        continue
                    }
                    if let l=Double(sb[1].filter { !$0.isWhitespace }) {
                        let v=sb[0]
                        plantList[v]=l
                        //print("Saw  Kc=\(l) for \(v), array count=\(plantList.count)")
                    }
                }
            } catch {
                // contents could not be loaded
                print("Do catch error")
            }
        } else {
            // example.txt not found!
            print("File not found")
        }
    }
    
    static func getKc(_ s:String) -> Double {
        if(plantList.count<2) {
            initialize()
        }
        return plantList[s] ?? -1.0
    }
}
