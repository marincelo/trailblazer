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
    pauseButton.enabled=false
    stopButton.enabled=false

    var db = LocalStorage.openDatabaseSync("Trailblazer", "1.0", "Trailblazer Workout Database", 1000000);
    db.transaction(
                function(tx) {
                                    tx.executeSql('INSERT INTO Workout VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)', [ distance.dist, duration.time, 10, weatherText.text, weatherImage.source, calories.text, new Date(), maxAltitude.text, 1.0, sportPopoverButton.text ]);

                                    var rs = tx.executeSql('SELECT * FROM Workout ORDER BY ROWID DESC');

                                    var r = "";
                                    previousWorkouts.clear();

                                    for(var i = 0; i < rs.rows.length; i++) {
                                        previousWorkouts.append({"distance":rs.rows.item(i).distance, "duration":rs.rows.item(i).duration, "date":new Date(rs.rows.item(i).date).toLocaleDateString(), "time":new Date(rs.rows.item(i).date).toTimeString().split(" ")[0] , "weatherImage": rs.rows.item(i).weatherImage, "weather":rs.rows.item(i).weather, "calories":rs.rows.item(i).calories, "maxSpeed":rs.rows.item(i).maxSpeed, "sport":rs.rows.item(i).sport})
                                    }
                                }
                       )

    distance.text = "0.0 km"
    duration.text = "0:00:00 hours"
    averageSpeed.text = "Avg Speed 0 km/h"
    calories.text = "Calories Burned"
    maxSpeed.text = "0.0 km/h"
    currentSpeed.text = "0.0 km/h"
    startButton.text = "Start"
}
