import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/service/weather_service.dart';

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  //api key
  final _weatherService=WeatherService("1404b0621a46174885d2b5c2b8a3a0de");
  Weather? _weather;

  //fetch weather
  _fetchweather()async{
    //get the current city
    String cityName=await _weatherService.getCurrentCity();

    //get the weather for city
    try{
      final weather=await _weatherService.getWeather(cityName);
      setState(() {
        _weather=weather;
      });
    }

    //get errors
    catch(e){
      log(e.toString());
    }
  }

  //weather animation
  String getWeatherAnimation(String? mainCondition){
    if(mainCondition==null) return 'assets/sunny.json';  //default

    switch(mainCondition.toLowerCase()){
      case 'clouds':
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return 'assets/cloud.json';
      case 'rain':
      case 'drizzle':
      case 'shower rain':
        return 'assets/rain.json';
      case 'thunderstorm':
        return 'assets/thunder.json';
      case 'clear':
        return 'assets/sunny.json';
      default:
        return 'assets/sunny.json';
    }
  }


  //init state
  @override
  void initState() {
    super.initState();
    //fetch weather on startup
    _fetchweather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            //city name
            Column(
              children: [
                const Icon(Icons.location_pin,size: 35,color: Colors.grey,),
                const SizedBox(height: 10,),
                Text(_weather?.cityName.toUpperCase() ?? "Loading city..",style: const TextStyle(fontSize: 24,fontWeight: FontWeight.w500),),
              ],
            ),


            Column(
              children: [
                //animation
                Lottie.asset(getWeatherAnimation(_weather?.mainCondition)),
                //weather condition
                Text(_weather?.mainCondition ?? "",style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w400),),
              ],
            ),

            //temperatur
            Text('${_weather?.temperature.round()??"Loading.."}°C',style: const TextStyle(fontSize: 28,fontWeight: FontWeight.w600),),

          ],
        ),
      ),
    );
  }
}
