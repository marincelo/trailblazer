function start(){
    durationTimer.start()
    gpsProvider.start()
    startButton.text = "Pause"
    //startButton.enabled=false
    //pauseButton.enabled=true
    stopButton.enabled=true

    var db = LocalStorage.openDatabaseSync("Trailblazer", "1.0", "Trailblazer Workout Database", 1000000);
      db.transaction(
                  function(tx) {

                      var rs = tx.executeSql('SELECT ROWID FROM Workout ORDER BY ROWID DESC LIMIT 1');

                      gpsTrail.workoutId=rs.rows.item(0).rowid+1

                                  }
                         )
}

function pause(){
    durationTimer.stop()
    gpsProvider.stop()
    //startButton.enabled=true
    startButton.text = "Resume"
    //pauseButton.enabled=false
    stopButton.enabled=true
    //for(var x=0;x<gpsTrail.count;x++)console.log(x + ": -" + gpsTrail.get(x).lat + "  " + gpsTrail.get(x).lon + "  " + gpsTrail.get(x).alt);
}

function finish(){
    durationTimer.stop()
    gpsProvider.stop()
    startButton.enabled=true
    startButton.text = "Start"
    //pauseButton.enabled=false
    stopButton.enabled=false

    var db = LocalStorage.openDatabaseSync("Trailblazer", "1.0", "Trailblazer Workout Database", 1000000);
    db.transaction(
                function(tx) {
                    tx.executeSql('INSERT INTO Workout VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [ mainCircle.dist, mainCircle.time, 10, buttonWeather.text, buttonWeather.iconSource, caloriesBurnt.text, new Date(), maxSpeed.text, 1.0, sportPopoverButton.text ]);

                                    var rs = tx.executeSql('SELECT * FROM Workout ORDER BY date DESC');

                                    var r = "";
                                    previousWorkouts.clear();

                                    for(var i = 0; i < rs.rows.length; i++) {
                                        previousWorkouts.append({"distance":rs.rows.item(i).distance, "duration":rs.rows.item(i).duration, "date":new Date(rs.rows.item(i).date).toLocaleDateString(), "time":new Date(rs.rows.item(i).date).toTimeString().split(" ")[0] , "weatherImage": rs.rows.item(i).weatherImage, "weather":rs.rows.item(i).weather, "calories":rs.rows.item(i).calories, "maxSpeed":rs.rows.item(i).maxSpeed, "sport":rs.rows.item(i).sport})
                                    }
                                }
                       )

    mainCircle.dist = 0.0
    mainCircle.time = 0.0
    startButton.text = "Start"
}

function add(date, sport, dist, dur, cal, wea){

    if(new Date(date))date=new Date(date);
    else date = new Date();

    switch(sport){
     case 0:
        sport = "Mountain Biking"
         break
     case 1:
        sport = "Cycling"
         break
     case 2:
        sport = "Running"
         break
     case 3:
        sport = "Walking"
         break
     default:
        sport = ""
         break
    }

    dur = parseInt(dur.split(":")[0])*3600 + parseInt(dur.split(":")[1])*60 + parseInt(dur.split(":")[2]);

    if(cal)cal = cal + " kcal";
    else cal="1000 kcal";

    var db = LocalStorage.openDatabaseSync("Trailblazer", "1.0", "Trailblazer Workout Database", 1000000);
    db.transaction(
                function(tx) {
                    tx.executeSql('INSERT INTO Workout VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [ dist, dur, 10, wea, buttonWeather.iconSource, cal, date, 10, 1.0, sport ]);

                                    var rs = tx.executeSql('SELECT * FROM Workout ORDER BY ROWID DESC');

                                    var r = "";
                                    previousWorkouts.clear();

                                    for(var i = 0; i < rs.rows.length; i++) {
                                        previousWorkouts.append({"distance":rs.rows.item(i).distance, "duration":rs.rows.item(i).duration, "date":new Date(rs.rows.item(i).date).toLocaleDateString(), "time":new Date(rs.rows.item(i).date).toTimeString().split(" ")[0] , "weatherImage": rs.rows.item(i).weatherImage, "weather":rs.rows.item(i).weather, "calories":rs.rows.item(i).calories, "maxSpeed":rs.rows.item(i).maxSpeed, "sport":rs.rows.item(i).sport})
                                    }
                                }
                       )
}
