import QtQuick 2.0
import QtQuick.LocalStorage 2.0
import Ubuntu.Components 0.1
import Ubuntu.Components.ListItems 0.1 as ListItem
import QtQuick.XmlListModel 2.0
import QtLocation 5.0
import Ubuntu.Components.Popups 0.1
import "main.js" as Trailblazer
import "workout.js" as Workout

MainView {
    id:root
    width: units.gu(45)
    height: units.gu(80)

    Tabs {
     ItemStyle.class:"new-tabs"
     id:main
     anchors.fill:parent

        Tab {
           id:workout
           title:i18n.tr("Workout")
           anchors.fill: parent
           page: Rectangle{
            anchors.fill:parent
            anchors.topMargin: units.gu(12)//there are issues with SDK at the moment. Normal margin is 2 gu
            gradient: Gradient {
                GradientStop {
                    position: 0.00;
                    color: "#ededf0";
                }
                GradientStop {
                    position: 1.00;
                    color: "#ffffff";
                }
            }

            Column {
                anchors.fill: parent
                height: parent.height-units.gu(10)
                spacing:units.gu(3)
                Row{
                    anchors.horizontalCenter: parent.horizontalCenter
                    Timer{
                        id:durationTimer
                        interval:1000
                        triggeredOnStart: true
                        repeat:true
                        onTriggered: {
                            mainCircle.time++
                        }
                    }

                    Rectangle {

//                        Image {
//                            id:backgroundImage
//                            source:"icons/circle.svg"
//                            width:(workout.width-units.gu(3))
//                            height:width
//                        }

                        id:mainCircle
                        property real dist:0.0
                        property real time:0.0
                        width:(workout.width-units.gu(4))
                        height:width
                        color: "#eee"
                        radius: width/2
                        border.width: units.gu(1)
                        border.color: "lightblue"
                        smooth:true
                        opacity:1
                        state:"default"

                        states:State {
                            name:"hidden"
                            PropertyChanges { target: mainCircle; opacity:0 }
                            PropertyChanges { target: mainCircle; visible:false }
                        }

                        transitions: [
                            Transition {
                                   from: "default"; to: "hidden"; reversible: true
                                   PropertyAnimation { target: mainCircle; properties: "opacity"; duration: 400; easing.type: Easing.OutCirc }
                               },
                            Transition {
                                   from: "hidden"; to: "default"; reversible: true
                                   PropertyAnimation { target: mainCircle; properties: "opacity"; duration: 400; easing.type: Easing.InCirc }
                               }]

                        MouseArea {
                            id:mainMouseArea
                            anchors.fill:parent
                            onClicked:{
                                mainCircle.state = "hidden"
                                altCircle.state = "visible"
                            }
                        }

                            Text {
                                anchors.bottom:centerText.top
                                anchors.bottomMargin: units.gu(2)
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:mainCircle.dist.toFixed(2)+" km"
                                color:"#dd4814"
                                font.family: "Ubuntu Light"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                font.pointSize: units.gu(3)
                            }

                            Text{
                                id:centerText
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                text:parseInt(mainCircle.time/3600)+":"+parseInt((mainCircle.time/60)%6)+parseInt((mainCircle.time/60)%10) +":"+parseInt((mainCircle.time/10)%6)+""+(mainCircle.time%10).toFixed(0)
                                color:"#dd4814"
                                font.family: "Ubuntu Light"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                font.pointSize: units.gu(6)

                            }

                            Text {
                                id:caloriesBurnt
                                anchors.top:centerText.bottom
                                anchors.topMargin: units.gu(2)
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:Trailblazer.countCalories()
                                color:"#dd4814"
                                font.family: "Ubuntu Light"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                font.pointSize: units.gu(3)
                            }
                    }

                    Rectangle {
                        id:altCircle
                        width:(workout.width-units.gu(4))
                        height:width
                        color: "#eee"
                        radius: width/2
                        border.width: units.gu(1)
                        border.color: "lightblue"
                        smooth:true
                        visible:false
                        opacity:0
                        state:"default"

                        states:State {
                            name:"visible"
                            PropertyChanges { target: altCircle; opacity:1}
                            PropertyChanges { target: altCircle; visible:true}
                        }

                        transitions: [
                            Transition {
                                   from: "default"; to: "visible"; reversible:true
                                   PropertyAnimation { target: altCircle; properties: "opacity"; duration: 400; easing.type: Easing.InCirc }
                               },
                            Transition {
                                   from: "visible"; to: "default"; reversible:true
                                   PropertyAnimation { target: altCircle; properties: "opacity"; duration: 400; easing.type: Easing.OutCirc }
                               }]

                        MouseArea {
                            anchors.fill:parent
                            onClicked:{
                                altCircle.state = "default"
                                mainCircle.state = "default"
                            }
                        }

                            Text {
                                id:maxSpeed
                                anchors.bottom:altCenterText.top
                                anchors.bottomMargin: units.gu(2)
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:"Max spd & alt"
                                color:"#dd4814"
                                font.family: "Ubuntu Light"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                font.pointSize: units.gu(3)
                            }

                            Text{
                                id:altCenterText
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.verticalCenter: parent.verticalCenter
                                text:(mainCircle.distance>0)?(mainCircle.distance/(mainCircle.duration/3600)).toFixed(2) + " km/h":"0 km/h"
                                color:"#dd4814"
                                font.family: "Ubuntu Light"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                font.pointSize: units.gu(6)

                            }

                            Text {
                                anchors.top:altCenterText.bottom
                                anchors.topMargin: units.gu(2)
                                anchors.horizontalCenter: parent.horizontalCenter
                                text:"Ascent/Descent"
                                color:"#dd4814"
                                font.family: "Ubuntu Light"
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                font.pointSize: units.gu(3)
                            }
                    }

            }

                Row{
                    spacing:units.gu(3)
                    anchors.horizontalCenter: parent.horizontalCenter

                    Button{
                        //START button starts the timer and gpsProvider and saves the data in 1 sec intervals(BAD)
                        //START and PAUSE are merged, onClicked event handles pause and start
                        id:startButton
                        text:"Start"
                        //color: "#5da357"
                        color:"lightblue"
                        height:units.gu(8)
                        width:units.gu(18)
                        onClicked:{
                            if(startButton.text==="Start" || startButton.text==="Resume")Workout.start()
                            else Workout.pause()
                        }
                        iconSource:"icons/playpause.svg"
                    }


                    Button{
                        //STOP button stops the timer and gpsProvider and saves the data to database
                        id:stopButton
                        enabled:false
                        text:"Finish"
                        //color: "#5da357"
                        color: "lightblue"
                        height:units.gu(8)
                        width:units.gu(18)
                        onClicked:Workout.finish()
                        iconSource:"icons/stop.svg"
                    }
                }

                Row{
                    anchors.horizontalCenter: parent.horizontalCenter
                    spacing: units.gu(1)
                    Column {
                        Button {
                            id:buttonWeather
                            color:"lightblue"
                            width:units.gu(20)
                            height:units.gu(8)
                            iconSource:"tick/dunno.png"
                            iconPosition:"left"
                            text:""
                            onClicked:{
                                PopupUtils.open(weatherPopoverLauncher, buttonWeather)
                                }
                        }

                        //WEATHER POPOVER

                        Component{
                            id:weatherPopoverLauncher

                            Popover {
                                id:weatherPopover
                                Column {
                                    anchors {
                                                left: parent.left
                                                top: parent.top
                                                right: parent.right
                                            }
                                    ListItem.Standard {
                                        text:buttonWeather.text
                                        icon:Image {
                                            width:units.gu(6)
                                            anchors.leftMargin: units.gu(1)
                                            anchors.rightMargin: units.gu(2)
                                            fillMode: Image.PreserveAspectFit
                                            source:buttonWeather.iconSource
                                        }

                                    }

                                    ListItem.Standard {
                                        text:weatherDetails.get(0).weather.get(0).description
                                    }

                                    ListItem.Standard {
                                        text:weatherDetails.get(0).name + " (" + weatherDetails.get(0).distance + " km)"
                                    }

                                    ListItem.Standard {
                                        text:weatherDetails.get(0).main.pressure + " hPa, " + weatherDetails.get(0).main.humidity + "% humidity"
                                    }

                                    ListItem.Standard {
                                        text:"Wind - " + (parseFloat(weatherDetails.get(0).wind.speed)*3.6).toFixed(1) + " km/h, " + weatherDetails.get(0).wind.deg + "°"
                                    }
                                }
                            }
                        }

                    }

                    Column {
                        Button{
                            id:"buttonSport"
                            color: "lightblue"
                            width:units.gu(20)
                            height:units.gu(8)
                            iconSource:switch(sportPopoverButton.text){
                                   case "Mountain Biking":
                                       return "icons/mtb.resized.png"
                                   case "Cycling":
                                       return "icons/cycling.resized.png"
                                   case "Walking":
                                       return "icons/walking.resized.png"
                                   case "Running":
                                       return "icons/running.resized.png"

                                   }
                            iconPosition:"left"
                            text:sportPopoverButton.text
                            onClicked:{
                                PopupUtils.open(sportPopoverLauncher, buttonSport)
                                }

                        }

                    }

                }

           }
        }
        }
        Tab{

            title:i18n.tr("History")

        PageStack{
                id:pageStack
                Component.onCompleted: pageStack.push(history)
                anchors.fill: parent

        Page {
            id:history
            Rectangle{
             anchors.fill:parent
             gradient: Gradient {
                 GradientStop {
                     position: 0.00;
                     color: "#ededf0";
                 }
                 GradientStop {
                     position: 1.00;
                     color: "#ffffff";
                 }
             }

                ListView{

                    Image{
                        id:addWorkout
                        fillMode: Image.PreserveAspectFit
                        anchors.right: parent.right
                        anchors.bottom:parent.bottom
                        source:"icons/plus.svg"
                        height:units.gu(4)
                        width:height
                        MouseArea {
                            anchors.fill: parent
                            onClicked:{
                                PopupUtils.open(addNewLauncher, addWorkout)
                            }

                            Component {
                                id:addNewLauncher

                                Popover {
                                    id:addNew
                                    Column {
                                        height:history.height*0.6
                                        //width:units.gu(10)
                                        spacing:units.gu(1)
                                        anchors.margins: units.gu(2)
                                        anchors{
                                            top:parent.top
                                            left:parent.left
                                            right:parent.right
                                        }
                                        Row {
                                            width:parent.width*0.75
                                            ListItem.ValueSelector{
                                                id:addSport
                                                text:"Sport"
                                                values:["Mountain Biking", "Cycling", "Running", "Walking"]
                                            }
                                        }
                                        Row {
                                            width:parent.width*0.75
                                            TextField {
                                                id:addDate
                                                width:parent.width
                                                placeholderText:"Date"
                                            }
                                        }
                                        Row {
                                            width:parent.width*0.75
                                            TextField {
                                                id:addDistance
                                                width:parent.width
                                                placeholderText:"Distance (km)"
                                            }
                                        }
                                        Row {
                                            width:parent.width*0.75
                                            TextField {
                                                id:addDuration
                                                width:parent.width
                                                placeholderText:"Duration"
                                            }
                                        }
                                        Row {
                                            width:parent.width*0.75
                                            TextField {
                                                id:addCalories
                                                width:parent.width
                                                placeholderText:"Calories burned (optional)"
                                            }
                                        }
                                        Row {
                                            width:parent.width*0.75
                                            TextField {
                                                id:addWeather
                                                width:parent.width
                                                placeholderText:"Weather (optional)"
                                            }
                                        }
                                        Row {
                                            width:parent.width*0.25
                                            Button {
                                                width:parent.width
                                                text:"Add"
                                                onClicked:{
                                                    Workout.add(addDate.text, addSport.selectedIndex, addDistance.text,addDuration.text,addCalories.text,addWeather.text)
                                                    PopupUtils.close(addNew);
                                                    previousWorkouts.clear();
                                                    Trailblazer.getHistory();
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }







                    id:historyList
                    clip:true
                    width:parent.width
                    height:parent.height
                    header:ListItem.MultiValue {
                        text: "Total "+previousWorkouts.count+" workouts"
                        values:["Distance: "+total.distance.toFixed(2) + " km", "Duration: "+(parseInt(total.duration/3600)+":"+parseInt((total.duration/60)%6)+parseInt((total.duration/60)%10) +":"+parseInt((total.duration/10)%6)+""+(total.duration%10).toFixed(0)) + " " + i18n.tr("hours"), "Calories: "+total.calories + " kcal"]
                    }
                    model:previousWorkouts

                    delegate:
                        ListItem.Standard{
                            text: parseFloat(distance).toFixed(2) + " km | "+(parseInt(duration/3600)+":"+parseInt((duration/60)%6)+parseInt((duration/60)%10) +":"+parseInt((duration/10)%6)+""+(duration%10).toFixed(0)) + " " + i18n.tr("hours") + " | " + calories
                            icon:Image {
                                fillMode: Image.PreserveAspectFit
                                source:switch(sport){
                                       case "Mountain Biking":
                                           return "icons/mtb.png"
                                       case "Cycling":
                                           return "icons/cycling.png"
                                       case "Walking":
                                           return "icons/walking.png"
                                       case "Running":
                                           return "icons/running.png"

                                       }
                                width:units.gu(6)
                        }

                        onClicked:{
                            ovDistance.text=parseFloat(distance).toFixed(2) + " km"
                            ovDuration.text=parseInt(duration/3600)+":"+parseInt((duration/60)%6)+parseInt((duration/60)%10) +":"+parseInt((duration/10)%6)+""+(duration%10).toFixed(0)
                            ovAvgSpeed.text=(distance/(duration/3600)).toFixed(2) + " km/h"
                            ovCalories.text=(distance*50).toFixed(0) + " kcal"
                            ovWeatherImage.source=weatherImage
                            ovWeather.text=weather
                            ovMaxSpeed.text=maxSpeed + " km/h"
                            var now = new Date(date)
                            overview.title=now.getFullYear()+"/"+(now.getMonth()+1)+"/"+now.getDate()
                            pageStack.push(overview)
                        }
                    }

                    section.property: "date"
                    section.criteria: ViewSection.FullString
                    section.delegate:ListItem.Header{
                                text:section
                    }

                }
            }
        }
        Page {
            id:overview
            title:i18n.tr("Overview")
            visible:false
            property string date:""
            property string distance:""
            property string duration:""

            Rectangle{
                anchors.fill:parent
                gradient: Gradient {
                     GradientStop {
                         position: 0.00;
                         color: "#ededf0";
                     }
                     GradientStop {
                         position: 1.00;
                         color: "#ffffff";
                     }
                }

             Column {
                 anchors.fill:parent
                 anchors.margins: units.gu(1)
                 spacing:units.gu(1)

                     ActivityIndicator {
                         id:imageLoading
                         height:(imageLoading.running)?units.gu(8):0
                         anchors.horizontalCenter: parent.horizontalCenter
                         running:mapImage.status==Image.Loading
                     }

                     Component {
                                 id: popoverWithFlickable

                                 Popover {
                                     id: popover

                                     Flickable {
                                         id: flickable
                                         anchors {
                                             left: parent.left
                                             right: parent.right
                                             top: parent.top
                                         }
                                         height: overview.height
                                         width:overview.width

                                         contentHeight: image.sourceSize.height
                                         contentWidth: image.sourceSize.width
                                         clip: true
                                         Image {
                                             id: image
                                             source: mapImage.source
                                             MouseArea {
                                                 id:imageFullscreenClose
                                                 anchors.fill: parent
                                                 onClicked:PopupUtils.close(popover)
                                             }

                                             PinchArea {
                                                id: pinchZoom
                                                anchors.fill: parent
                                                pinch.target:image
                                                onPinchStarted: {
                                                    console.log("pinch");
                                                }
                                             }

                                         }
                                     }
                                 }
                             }

                 Image {
                     id:mapImage
                     width:parent.width-units.gu(1)
                     anchors.horizontalCenter: parent.horizontalCenter
                     fillMode: Image.PreserveAspectFit
//                    source: "http://maps.googleapis.com/maps/api/staticmap?center=43.500752,16.273041&zoom=12&size=400x200&sensor=false"
                     source:"staticmap.png"

                    MouseArea {
                        id:imageFullscreen
                        anchors.fill: parent
                        onClicked:PopupUtils.open(popoverWithFlickable, overview)
                    }
                }

                 Row {
                     anchors.horizontalCenter: parent.horizontalCenter
                     spacing:units.gu(2)
                    Column {

                        UbuntuShape{
                            color:"#aaa"
                            radius:"medium"
                            width:units.gu(16)

                            Text {
                                id:ovDistance
                                text:"Distance"
                                font.pointSize: units.gu(1.6)
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                anchors.fill:parent
                            }

                        }
                    }

                    Column {

                        UbuntuShape{
                            color:"#aaa"
                            radius:"medium"
                            width:units.gu(16)

                            Text {
                                id:ovDuration
                                text:"Duration"
                                font.pointSize: units.gu(1.6)
                                verticalAlignment: Text.AlignVCenter
                                horizontalAlignment: Text.AlignHCenter
                                anchors.fill:parent
                            }


                        }
                    }
                 }

                 Row {
                     anchors.horizontalCenter: parent.horizontalCenter
                     spacing:units.gu(2)
                     Column {

                         UbuntuShape{
                             color:"#aaa"
                             radius:"medium"
                             width:units.gu(16)

                             Text {
                                 id:ovAvgSpeed
                                 text:"Avg Speed"
                                 font.pointSize: units.gu(1.6)
                                 verticalAlignment: Text.AlignVCenter
                                 horizontalAlignment: Text.AlignHCenter
                                 anchors.fill:parent
                             }


                         }
                     }

                     Column {

                         UbuntuShape{
                             color:"#aaa"
                             radius:"medium"
                             width:units.gu(16)

                             Text {
                                 id:ovCalories
                                 text:"Calories"
                                 font.pointSize: units.gu(1.6)
                                 verticalAlignment: Text.AlignVCenter
                                 horizontalAlignment: Text.AlignHCenter
                                 anchors.fill:parent
                             }


                         }
                     }
                 }

                 Row {
                     anchors.horizontalCenter: parent.horizontalCenter
                     spacing:units.gu(2)
                     Column {

                         UbuntuShape{
                             color:"#aaa"
                             radius:"medium"
                             width:units.gu(16)


                             Image{
                                 id:ovWeatherImage
                                 anchors.left:parent.left
                                 anchors.leftMargin: units.gu(1.6)
                                 anchors.verticalCenter: parent.verticalCenter
                                 source:"tick/dunno.png"
                                 fillMode: Image.PreserveAspectFit
                                 height: units.gu(5)
                                 smooth:true
                                 horizontalAlignment: Text.AlignHCenter
                                 verticalAlignment: Text.AlignVCenter
                             }

                             Text {
                                 id:ovWeather
                                 text:"Not available"
                                 font.pointSize: units.gu(1)
                                 verticalAlignment: Text.AlignVCenter
                                 horizontalAlignment: Text.AlignHCenter
                                 anchors.fill:parent
                             }


                         }
                     }

                     Column {

                         UbuntuShape{
                             color:"#aaa"
                             radius:"medium"
                             width:units.gu(16)

                             Text {
                                 id:ovMaxSpeed
                                 text:"Max Speed"
                                 font.pointSize: units.gu(1.6)
                                 verticalAlignment: Text.AlignVCenter
                                 horizontalAlignment: Text.AlignHCenter
                                 anchors.fill:parent
                             }


                         }
                     }
                 }

                 Row {
                     anchors.horizontalCenter: parent.horizontalCenter
                     spacing:units.gu(2)
                     Column {

                         UbuntuShape{
                             color:"#aaa"
                             radius:"medium"
                             width:units.gu(16)

                             Text {
                                 id:ovMaxalt
                                 text:"Max Altitude" //Math.max.apply(Math, array);
                                 font.pointSize: units.gu(1.6)
                                 verticalAlignment: Text.AlignVCenter
                                 horizontalAlignment: Text.AlignHCenter
                                 anchors.fill:parent
                             }


                         }
                     }

                     Column {

                         UbuntuShape{
                             color:"#aaa"
                             radius:"medium"
                             width:units.gu(16)

                             Text {
                                 id:ovMinalt
                                 text:"Min Altitude"
                                 font.pointSize: units.gu(1.6)
                                 verticalAlignment: Text.AlignVCenter
                                 horizontalAlignment: Text.AlignHCenter
                                 anchors.fill:parent
                             }


                         }
                     }
                 }

             }
            }
        }
        }
        }

        Tab {
            id:settings
            title:i18n.tr("Settings")
            anchors.fill: parent
            page: Rectangle{
             anchors.fill:parent
             anchors.topMargin:units.gu(12)//change to 2 gu when SDK gets it shit together
             gradient: Gradient {
                 GradientStop {
                     position: 0.00;
                     color: "#ededf0";
                 }
                 GradientStop {
                     position: 1.00;
                     color: "#ffffff";
                 }
             }
            Column {
                spacing:units.gu(2)
                anchors.fill: parent
              Row {
                  width:parent.width
                  anchors.horizontalCenter: parent.horizontalCenter
                Column {
                    width:parent.width/2
                    Text{
                        id:unitsString
                        anchors.left: parent.left
                        anchors.margins: units.gu(1)
                        property bool metric:true
                        color: "#555"
                        text:i18n.tr("Units - Metric")
                        font.pointSize: units.gu(1.6)
                    }
                }
                Column{
                    width:parent.width/2
                        Button{
                            id:unitsSwitch
                            text:i18n.tr("Change")
                            width:units.gu(16)
                            anchors.right: parent.right
                            anchors.margins: units.gu(1)
                            onClicked:{
                                unitsString.text=(unitsString.metric)?i18n.tr("Units - Imperial"):i18n.tr("Units - Metric");
                                unitsString.metric=!unitsString.metric;
                                var db = LocalStorage.openDatabaseSync("Trailblazer", "1.0", "Trailblazer Workout Database", 1000000);
                                  db.transaction(
                                              function(tx) {
                                                  tx.executeSql('UPDATE Settings SET value='+((unitsString.metric)?1:0)+' WHERE NAME=\'units\'');
                                                        }
                                                  )
                                }
                        }
                    }
                }

               Row {
                   anchors.horizontalCenter: parent.horizontalCenter
                   width:parent.width
                   Column {
                       width:parent.width/4
                       Text {
                           text:"Weight (kg)"
                            verticalAlignment: Text.AlignVCenter
                            color: "#555"
                           font.pointSize: units.gu(1.6)
                           anchors.left: parent.left
                           anchors.margins: units.gu(1)
                       }
                   }
                    Column{
                        width:parent.width*3/4

                        Slider {
                            id:weightSlider
                            anchors.right: parent.right
                            anchors.margins: units.gu(1)
                            minimumValue:30
                            maximumValue:200
                            width:units.gu(26)
                            live:false

                            //Here's onClicked event which doesn't fire if slider is dragged. Need to change this!

                            onClicked:{
                                console.log('UPDATE Settings SET value='+(weightSlider.value.toFixed(0))+' WHERE NAME=\'weight\'')
                                var db = LocalStorage.openDatabaseSync("Trailblazer", "1.0", "Trailblazer Workout Database", 1000000);
                                  db.transaction(
                                              function(tx) {
                                                  tx.executeSql('UPDATE Settings SET value='+(weightSlider.value.toFixed(0))+' WHERE NAME=\'weight\'');
                                                        }
                                                  )
                                }
                            }
                        }

                    }

               Row {
                   id:sportRow
                   anchors.horizontalCenter: parent.horizontalCenter
                   width:parent.width
                   visible:false
                   Column {
                       width:parent.width/2
                       Text {
                           id:sport
                           text:"Sport"
                            verticalAlignment: Text.AlignVCenter
                            color: "#555"
                           font.pointSize: units.gu(1.6)
                           anchors.left: parent.left
                           anchors.margins: units.gu(1)
                       }
                   }
                    Column{
                        width:parent.width/2
                        Button{
                            id:sportPopoverButton
                            width:units.gu(26)
                            anchors.right: parent.right
                            anchors.margins: units.gu(1)
                            onClicked:{
                                PopupUtils.open(sportPopoverLauncher, sportPopoverButton)
                                }
                        }

                        Component {
                            id:sportPopoverLauncher

                        Popover {
                            id:sportPopover
                            Column {
                                anchors {
                                            left: parent.left
                                            top: parent.top
                                            right: parent.right
                                        }
                                        ListItem.Standard {
                                            text:"Mountain Biking"
                                            icon:Image {
                                                width:units.gu(6)
                                                anchors.leftMargin: units.gu(1)
                                                anchors.rightMargin: units.gu(2)
                                                fillMode: Image.PreserveAspectFit
                                                source:"icons/mtb.png"
                                            }

                                            onClicked: {
                                                sportPopoverButton.text = "Mountain Biking"
                                                PopupUtils.close(sportPopover)
                                                var db = LocalStorage.openDatabaseSync("Trailblazer", "1.0", "Trailblazer Workout Database", 1000000);
                                                  db.transaction(
                                                              function(tx) {
                                                                  tx.executeSql('UPDATE Settings SET value=0 WHERE NAME=\'sport\'');
                                                                        }
                                                                  )
                                            }
                                        }
                                        ListItem.Standard {
                                            text:"Cycling"
                                            icon:Image {
                                                width:units.gu(6)
                                                anchors.leftMargin: units.gu(1)
                                                anchors.rightMargin: units.gu(2)
                                                fillMode: Image.PreserveAspectFit
                                                source:"icons/cycling.png"
                                            }
                                            onClicked: {
                                                sportPopoverButton.text = "Cycling"
                                                PopupUtils.close(sportPopover)
                                                var db = LocalStorage.openDatabaseSync("Trailblazer", "1.0", "Trailblazer Workout Database", 1000000);
                                                  db.transaction(
                                                              function(tx) {
                                                                  tx.executeSql('UPDATE Settings SET value=1 WHERE NAME=\'sport\'');
                                                                        }
                                                                  )
                                            }
                                        }
                                        ListItem.Standard {
                                            text:"Running"
                                            icon:Image {
                                                width:units.gu(6)
                                                anchors.leftMargin: units.gu(1)
                                                anchors.rightMargin: units.gu(2)
                                                fillMode: Image.PreserveAspectFit
                                                source:"icons/running.png"
                                            }
                                            onClicked: {
                                                sportPopoverButton.text = "Running"
                                                PopupUtils.close(sportPopover)
                                                var db = LocalStorage.openDatabaseSync("Trailblazer", "1.0", "Trailblazer Workout Database", 1000000);
                                                  db.transaction(
                                                              function(tx) {
                                                                  tx.executeSql('UPDATE Settings SET value=2 WHERE NAME=\'sport\'');
                                                                        }
                                                                  )
                                            }
                                        }
                                        ListItem.Standard {
                                            text:"Walking"
                                            icon:Image {
                                                width:units.gu(6)
                                                anchors.leftMargin: units.gu(1)
                                                anchors.rightMargin: units.gu(2)
                                                fillMode: Image.PreserveAspectFit
                                                source:"icons/walking.png"
                                            }
                                            onClicked: {
                                                sportPopoverButton.text = "Walking"
                                                PopupUtils.close(sportPopover)
                                                var db = LocalStorage.openDatabaseSync("Trailblazer", "1.0", "Trailblazer Workout Database", 1000000);
                                                  db.transaction(
                                                              function(tx) {
                                                                  tx.executeSql('UPDATE Settings SET value=3 WHERE NAME=\'sport\'');
                                                                        }
                                                                  )
                                            }
                                        }
                                }
                            }
                        }
                    }
                }

                }
             }

        }

    }


    ListModel{
     id:previousWorkouts

    }

    ListModel {
        id:gpsTrail
        property int workoutId: 0
    }

    ListModel {
        id:weatherDetails
    }

    //THIS CAN BE USED TO IMPORT GPX FILES
    ListModel {
        id:imported
    }

    XmlListModel {
        id:gpx
        //source:"endo.gpx"
        query:"/gpx/trk/trkseg/trkpt"
        namespaceDeclarations: "declare default element namespace \"http://www.topografix.com/GPX/1/1\";"
        onStatusChanged: {
                if (status === XmlListModel.Ready) {
                    for (var i = 0; i < count; i++){
                        imported.append({"lat": gpx.get(i).lat, "lon": gpx.get(i).lon, "time": gpx.get(i).time, "alt": gpx.get(i).alt})
                    }
                    Trailblazer.spinData();
                }
            }
        XmlRole {name:"lat";query:"@lat/string()"}
        XmlRole {name:"lon";query:"@lon/string()"}
        XmlRole {name:"time";query:"time/string()"}
        XmlRole {name:"alt";query:"ele/string()"}


    }
    //END OF GPX PART

    Item{

        //THIS LOADS WORKOUT HISTORY WHEN APP IS LOADED - COMPONENT IS root MainView
        Component.onCompleted: {
            Trailblazer.getHistory()
            Trailblazer.getWeather();
        }
    }

    PositionSource {
        id:gpsProvider
        //preferredPositioningMethods:PositionSource.SatellitePositioningMethod
        nmeaSource:"nmea_data"
        active:false
        onPositionChanged:{
            gpsTrail.append({lat:gpsProvider.position.coordinate.latitude, lon:gpsProvider.position.coordinate.longitude, alt:gpsProvider.position.coordinate.altitude, time:gpsProvider.position.timestamp});

            var last = gpsTrail.get(gpsTrail.count-2);

            console.log("Speed is: " + Trailblazer.calculateDistance(last.lat, last.lon, gpsProvider.position.coordinate.latitude,gpsProvider.position.coordinate.longitude)/((gpsProvider.position.timestamp-last.time)/3600000) + " km/h");

            mainCircle.dist += Trailblazer.calculateDistance(last.lat, last.lon, gpsProvider.position.coordinate.latitude,gpsProvider.position.coordinate.longitude);

            if(gpsTrail.count > 2) if(gpsProvider.position.coordinate.distanceTo(last.lat, last.lon) > 0)console.log("DistanceTo() is working!!");
            //console.log("Accuracy: "+gpsProvider.position.coordinate.isValid);

            //if(gpsProvider.position.speedValid)currentSpeed.text=(gpsProvider.position.speed*3.6).toFixed(2)+"km/h";

            var db = LocalStorage.openDatabaseSync("Trailblazer", "1.0", "Trailblazer Workout Database", 1000000);
              db.transaction(
                          function(tx) {
                                var rs = tx.executeSql('SELECT * FROM Workout ORDER BY date DESC');
                                tx.executeSql('INSERT INTO Points VALUES(?, ?, ?, ?, ?)', [gpsTrail.workoutId, position.coordinate.latitude, position.coordinate.longitude, position.coordinate.altitude, position.timestamp]);

                                    }
                              )
        }
    }


    Item {
        id:total
        property real distance:0
        property int duration:0
        property int calories:0
    }

}
