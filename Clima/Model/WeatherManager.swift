//
//  WeatherManager.swift
//  Clima
//
//  Created by Utku Güzel on 1.05.2023.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=814c3c0af373e14427a6ccef083209bc&units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    
    func fetcWeather(cityName: String) {
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetcWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
        
    }
    
    
    func performRequest(with urlString: String) {
        //1. Create a URL
        if let url = URL(string: urlString) {
            //2. Create a URLSession
            let session = URLSession(configuration: .default)
            //3. Give the session a task
            let task = session.dataTask(with: url) { (data, response, error) in
                if error != nil {
                    delegate?.didFailWithError(error: error!)
                    return
                }
                
                if let safeData = data {
                    if let weather = parseJSON(safeData) {
                        delegate?.didUpdateWeather(self, weather: weather)
                        
                    }
                }
            }
            //4. Start the task
            task.resume()
        }
    }
    
    
    func parseJSON(_ weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            let weather = WeatherModel(conditionID: id, cityName: name, temperature: temp)
            return weather
                        
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
    
}
