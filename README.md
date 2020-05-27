# thermo_widget

Flutter project containing Thermo widget and demo app.

## Demo

![Slider example](demo.gif)

## Constructor

| Parameter |   Default   | Description |
|----------|:-------------:|------:|
| divisions | required | Number of sectors in which the slider is divided(# of possible values on the slider) |
| initialHandlerValues | required | Map containing information about day configuration |
| height | 300.0 | Height of the canvas where the widget is rendered |
| width | 300.0 | Width of the canvas where the widget is rendered |
| child | null | Widget that will be inserted in the center of the circular slider |
| primarySectors | 0 | Number of primary sectors to be painted on the base circular crown |
| secondarySectors | 0 | Number of secondary sectors to be painted on the base circular crown |
| this.baseColor | Color.fromRGBO(255, 255, 255, 0.1) | Color of the base circular crown |
| this.hoursColor | Color.fromRGBO(255, 255, 255, 0.3) | Color of lines which represent hours(primarySectors) |
| this.minutesColor | Colors.white30 | Color of lines which represent minutes(secondarySectors) |
| this.handlerColor | Colors.white | Color of the handlers |
| this.onSelectionChange | void SelectionChanged<Map<int, Map<String, dynamic>>> | Function triggered when at least one of the handler positions changes or the user moves the circular crown |
| this.onSelectionEnd | void SelectionChanged<Map<int, Map<String, dynamic>>> | Function triggered when the user stop changing handler positions or moving the circular crown |
| this.handlerOutterRadius | 22.0 | Radius of the outter circle of the handler |
| this.sliderStrokeWidth | 28.0 | Stroke width for the slider |

## Adding Flutter Web to an existing flutter app.

For adding web support to an existing app we need to run these commands:
```
 flutter channel beta
 flutter upgrade
 flutter config --enable-web
```
Then check that Chrome is ready:
```
flutter devices
```
**Restart your IDE** and go to the project root folder, run:
```
flutter create .
```
To serve your app from localhost in Chrome, enter the following from the top of the package:
```
flutter run -d chrome
```

### Build web
Run the following command to generate a release build:
```
flutter build web
```
A release build uses dart2js (instead of the development compiler) to produce a single JavaScript 
file main.dart.js. You can create a release build using release mode (flutter run --release) or by
using flutter build web. This populates a build/web directory with built files, including an assets
directory, which need to be served together.

### Run web
Launch a web server (for example, python -m SimpleHTTPServer 8000, or by using the dhttpd package),
and open the /build/web directory. Navigate to localhost:8000 in your browser (given the python
SimpleHTTPServer example) to view the release version of your app.

#### Run with dhttpd web server
Install dhttpd with the following command:
```
flutter pub global activate dhttpd
```
Go to build */build/web* directory and run:
```
flutter pub global run dhttpd
```
Open your browser and navigate to **http://localhost:8080**

#### Embedding a Flutter app into an HTML page
You can embed a Flutter web app, as you would embed other content, in an iframe tag of an HTML file.
Change /build/web/index.html name. Create a new index.html with the iframe tag reporting as url the
url of the old index.html.
In the following example, replace “URL” with the location of your HTML page:
```
<iframe src="URL"></iframe>
```
More info at **https://flutter.dev/docs/deployment/web** .


