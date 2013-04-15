function getHistory(){
    var start = new Date().getTime()

    var db = LocalStorage.openDatabaseSync("Trailblazer", "1.0", "Trailblazer Workout Database", 1000000);
        db.transaction(
                function(tx) {
                    //WORKOUT TABLE
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Workout(distance FLOAT, duration INTEGER, maxSpeed DECIMAL, weather STRING, weatherImage STRING, calories STRING, date STRING, maxAltitude DECIMAL, minAltitude DECIMAL, sport STRING)');
                    //GPS POINTS TABLE
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Points(rowId INTEGER, latitude FLOAT, longitude FLOAT, altitude DECIMAL, timestamp STRING)');
                    //SETTINGS TABLE
                        tx.executeSql('CREATE TABLE IF NOT EXISTS Settings(name STRING, value INTEGER)');
                    var count = tx.executeSql('SELECT * from Settings ORDER BY ROWID DESC LIMIT 1');
                    //IF Settings table is empty, fill with default values - this is executed only after install
                    if (!(count.rows.item(0) !==undefined)){
                        tx.executeSql('INSERT INTO Settings VALUES(?, ?)', ["units", 1]);
                        tx.executeSql('INSERT INTO Settings VALUES(?, ?)', ["woeid", 850357]);
                        tx.executeSql('INSERT INTO Settings VALUES(?, ?)', ["weight", 70]);
                        tx.executeSql('INSERT INTO Settings VALUES(?, ?)', ["sport", 0]);
                    }
                    //ELSE - load settings
                    else {
                        var set = tx.executeSql('SELECT name, value from Settings');
                        for(var i = 0; i < set.rows.length; i++) {
                            if(set.rows.item(i).name==="weight")weightSlider.value = parseInt(set.rows.item(i).value)
                            if(set.rows.item(i).name==="units"){
                                unitsString.metric=(set.rows.item(i).value==="1")
                                unitsString.text=(set.rows.item(i).value==="1")?"Units - Metric":"Units - Imperial"
                                  }
                            if(set.rows.item(i).name==="sport"){
                                if(parseInt(set.rows.item(i).value)===0)sportPopoverButton.text = "Mountain Biking"
                                else if(parseInt(set.rows.item(i).value)===1)sportPopoverButton.text ="Cycling"
                                else if(parseInt(set.rows.item(i).value)===2)sportPopoverButton.text = "Running"
                                else if(parseInt(set.rows.item(i).value)===3)sportPopoverButton.text = "Walking"
                                else sportPopoverButton.text = "Choose sport"
                            }

                        }
                    }

                        var rs = tx.executeSql('SELECT * FROM Workout ORDER BY date DESC');

                    history.title="Total "+rs.rows.length+" workouts";

                        var r = ""
                            for(var i = 0; i < rs.rows.length; i++) {
                                total.distance += rs.rows.item(i).distance;
                                total.duration += rs.rows.item(i).duration;
                                total.calories += parseInt(rs.rows.item(i).calories.split(" ")[0]);

                                previousWorkouts.append({"distance":rs.rows.item(i).distance, "duration":rs.rows.item(i).duration, "date":new Date(rs.rows.item(i).date).toLocaleDateString(), "time":new Date(rs.rows.item(i).date).toTimeString().split(" ")[0] , "weatherImage": rs.rows.item(i).weatherImage, "weather":rs.rows.item(i).weather, "calories":rs.rows.item(i).calories, "maxSpeed":rs.rows.item(i).maxSpeed, "sport":rs.rows.item(i).sport})
                                      }
                                  }
                         )

    console.log("GPS active? " + gpsProvider.valid);//Return a message to the user if GPS is disabled
    console.log("GetHistory takes: "+(new Date().getTime()-start)+" ms")

}

function countCalories(){
    var sp = sportPopoverButton.text
    var units = unitsString.metric

    //TO-DO change MET values depending on AVG SPEED and (Max-Min) Altitude

    if(sp === "Mountain Biking")//MET = 8.5
        return (8.5*weightSlider.value*mainCircle.time/3600).toFixed(0) + " kcal"
    else if(sp === "Running")
        return (weightSlider.value*mainCircle.dist).toFixed(0) + " kcal"
    else if(sp === "Walking")
        return (0.8*weightSlider.value*mainCircle.dist).toFixed(0) + " kcal"
    else if (sp === "Cycling")//MET = 12
             return (12*weightSlider.value*mainCircle.time/3600).toFixed(0) + " kcal"
    else return "Choose Sport"
}

function getWeather(){
    var xhr = new XMLHttpRequest();

    gpsProvider.update();

    xhr.open("GET", "http://api.openweathermap.org/data/2.1/find/city?lat=" +gpsProvider.position.coordinate.latitude.toFixed(6)+ "&lon=" +gpsProvider.position.coordinate.longitude.toFixed(6)+ "&cnt=1&APPID=4cb86409f0202a6fba4ffea5058a5625", true);

    console.log("http://api.openweathermap.org/data/2.1/find/city?lat=" +gpsProvider.position.coordinate.latitude.toFixed(6)+ "&lon=" +gpsProvider.position.coordinate.longitude.toFixed(6)+ "&cnt=1");

    xhr.onreadystatechange = function(){
        if(xhr.readyState == xhr.DONE && xhr.status == 200){
            var json = eval('(' + xhr.responseText + ')');

            weatherDetails.append(json.list[0]);

            buttonWeather.text= json.list[0].weather[0].main + ", " + ((parseFloat(json.list[0].main.temp)-273.15).toFixed(1)) +" °C"
            switch(json.list[0].weather[0].icon){
                case "01d":
                    buttonWeather.iconSource =  "tick/sunny.png"
                    return
                case "01n":
                    buttonWeather.iconSource =  "tick/sunny_night.png"
                    return
                case "02d":
                    buttonWeather.iconSource =  "tick/cloudy1.png"
                    return
                case "02n":
                    buttonWeather.iconSource =  "tick/cloudy1_night.png"
                    return
                case "03d":
                    buttonWeather.iconSource = "tick/cloudy2.png"
                    return
                case "03n":
                    buttonWeather.iconSource = "tick/cloudy2_night.png"
                    return
                case "04d":
                    buttonWeather.iconSource = "tick/cloudy3.png"
                    return
                case "04n":
                    buttonWeather.iconSource = "tick/cloudy3_night.png"
                    return
                case "09d":
                    buttonWeather.iconSource = "tick/shower3.png"
                    return
                case "09n":
                    buttonWeather.iconSource = "tick/shower2_night.png"
                    return
                case "10d":
                    buttonWeather.iconSource = "tick/light_rain.png"
                    return
                case "10n":
                    buttonWeather.iconSource = "tick/light_rain.png"
                    return
                case "11d":
                    buttonWeather.iconSource = "tick/tstorm3.png"
                    return
                case "11n":
                    buttonWeather.iconSource = "tick/tstorm2_night.png"
                    return
                case "13d":
                    buttonWeather.iconSource = "tick/snow4.png"
                    return
                case "13n":
                    buttonWeather.iconSource = "tick/snow3_night.png"
                    return
                case "50d":
                    buttonWeather.iconSource = "tick/mist.png"
                    return
                case "50n":
                    buttonWeather.iconSource = "tick/mist_night.png"
                    return
                default:
                    buttonWeather.iconSource = "tick/dunno.png"

            }
        }

    }

    //xhr.send();
}

function calculateDistance(lat1, long1, lat2, long2){

    var R = 6371; // km
    lat1 = lat1*Math.PI / 180;
    lat2 = lat2*Math.PI / 180;
    long1 = long1*Math.PI / 180;
    long2 = long2*Math.PI / 180;

    var d = Math.acos(Math.sin(lat1)*Math.sin(lat2) +
                      Math.cos(lat1)*Math.cos(lat2) *
                      Math.cos(long2-long1)) * R;
    return d;

}

function spinData(){
    for(var x =0;x<imported.count;x++)console.log(x + ": " +imported.get(x).lat + " - " + imported.get(x).lon + " : " + imported.get(x).alt + "m, at " + imported.get(x).time);

    console.log("Counts" + imported.count);
}
