//
//  WeatherManager.swift
//  Clima
//
//  Created by Afseen Salam on 3/13/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation
protocol WeatherManagerDelegate {
    func didUpdateWeather(weather : weatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL =
    "https://api.openweathermap.org/data/2.5/weather?APPID=3a593e0a5c460a0ce5ee2def15610f3e&units=metric"
    var delegate : WeatherManagerDelegate?
    func fetchData(latitude: CLLocationDegrees,longitude:CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        let turlString = urlString.trimmingCharacters(in: .whitespaces)
        
        performRequest(urlString:turlString)
        
    }
    func fetchData(cityName : String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        let turlString = urlString.trimmingCharacters(in: .whitespaces)
        
        performRequest(urlString:turlString)
    }
    func performRequest(urlString: String){
        // 1.create an url
        if   let url = URL(string: urlString){
            print(url)
            // 2. create a session
            let session = URLSession(configuration: .default)
            //3. assign a task
    let task = session.dataTask(with: url) {(data,response,error) in
                if error != nil{
                    delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data{
                    if  let weather = parseJSON(weatherData:safeData){
                        self.delegate?.didUpdateWeather(weather: weather)
                    }
                    }
                    
                }
                //4.start the task
                task.resume()
            }
            
        }
        func parseJSON(weatherData: Data)-> weatherModel?{
            //print(String(data: weatherData, encoding: .utf8)!)
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
                let id = decodedData.weather[0].id
                let name = decodedData.name
                let temp = decodedData.main.temp
                let weather = weatherModel(cityName: name, temperature: temp, conditionId: id)
                return weather
                
            }catch {
                delegate?.didFailWithError(error: error)
                return nil
            }
        }
        
    }
