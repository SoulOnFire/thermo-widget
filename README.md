# thermo_widget

Flutter project containing the new Thermo widget and demo app.

## Demo

![Slider example](demo.gif)

## Constructor

| Parameter | Default  |                                                                        Description                                                                                         |
| --------- | -------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| divisions | required | Number of sectors in which the slider is divided(# of possible values on the slider), max value is 300.                                                                    |
| firstValue | required | Initial value in which is located first handler                                                                                                                           |
| secondValue | required | Initial value in which is located second handler                                                                                                                         |
| thirdValue | required | Initial value in which is located third handler                                                                                                                           | 
| fourthValue | required | Initial value in which is located fourth handler                                                                                                                         |
| height | 300.0 | Height of the canvas where the slider is rendered                                                                                                                                |
| width | 300.0 | Width of the canvas where the slider is rendered                                                                                                                                  |
| child | null | An optional widget that will be inserted inside the slider                                                                                                                         |
| primarySectors | 0 | The number of primary sectors to be painted, they will be painted using hoursColor                                                                                           |
| secondarySectors | 0 | The number of secondary sectors to be painted, they will be painted using minutesColor                                                                                     |
| baseColor | Color.fromRGBO(255, 255, 255, 0.1) | Color of the base circle                                                                                                                         |
| hoursColor| Color.fromRGBO(255, 255, 255, 0.3) | Color of lines which represent hours(primarySectors )                                                                                            |
| minutesColor | Colors.white30 | Color of lines which represent minutes(secondarySectors)                                                                                                          |
| section12Color | Colors.amber | Color of the section between handler #1 and handler #2.                                                                                                           |
| section23Color | Colors.blue | Color of the section between handler #2 and handler #3                                                                                                             |
| section34Color | Colors.deepPurpleAccent | Color of the section between handler #3 and handler #4                                                                                                 |
| section41Color | Colors.brown | Color of the section between handler #4 and handler #1                                                                                                            |
| handlerColor | Colors.white | Color of the handlers                                                                                                                                               |
| onSelectionChange | void onSelectionChange(int newFirst,int newSecond,int newThird,int newForth) | Function called when at least one of firstValue,secondValue,thirdValue,fourthValue changes     |
| onSelectionEnd | void onSelectionEnd(int newFirst,int newSecond,int newThird,int newForth) | Function called when the user stop changing firstValue,secondValue,thirdValue,fourthValue values     |
| handlerOutterRadius | 22.0 | Radius of the outter circle of the handler |
| sliderStrokeWidth | 28.0 | Stroke width for the slider |
