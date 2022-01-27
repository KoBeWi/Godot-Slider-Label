# <img src="https://github.com/KoBeWi/Godot-Slider-Label/blob/master/Media/Icon.png" width="64" height="64"> Godot Slider Label

![](https://github.com/KoBeWi/Godot-Slider-Label/blob/master/Media/ReadmeIntro.gif)

^ This can be your Slider, just install this plugin.

## Usage

After SliderLabel plugin is enabled, you can add a new SliderLabel node onto your scene. The node needs to be a child of Slider. Done. Your Slider will now display the value. You can customize the label formatting, like color, font (size) etc. and it will all display correctly. The label updates when slider's value changes. The label also automatically adjusts depending if used with HSlider or VSlider.

![](https://github.com/KoBeWi/Godot-Slider-Label/blob/master/Media/ReadmeStyling.gif)

## Settings

SliderLabel comes with a few custom settings that can be used to customize its behavior. Note that you can't change them at runtime.

### Visibility Rule

Controls when the label will display. The options are:

- On Click - label will display when the slider is being clicked.

![](https://github.com/KoBeWi/Godot-Slider-Label/blob/master/Media/ReadmeShowClick.gif)

- On Hover - label will display when it's being hovered by cursor.

![](https://github.com/KoBeWi/Godot-Slider-Label/blob/master/Media/ReadmeShowHover.gif)

- On Focus - label will display when it's currently focused. Works also with keyboard focus.

![](https://github.com/KoBeWi/Godot-Slider-Label/blob/master/Media/ReadmeShowHover.gif)

- Always - label will display.

![](https://github.com/KoBeWi/Godot-Slider-Label/blob/master/Media/ReadmeShowAlways.png)

### Placement

Determines the side of the slider on which the label will be placed. Top/Bottom applies to HSlider and Right/Left to VSlider.

![](https://github.com/KoBeWi/Godot-Slider-Label/blob/master/Media/ReadmePlacementTopLeft.png)
![](https://github.com/KoBeWi/Godot-Slider-Label/blob/master/Media/ReadmePlacementBottomRight.png)

### Separation

The space in pixels between label's and slider's rects.

![](https://github.com/KoBeWi/Godot-Slider-Label/blob/master/Media/ReadmeSeparation.png)

### Custom Format

Specifies the custom formatting for the value display. Requires exactly one placeholder (`%s`/`%d`/`%f`). You can also use it to display suffixes etc. Leave empty for no formatting.

![](https://github.com/KoBeWi/Godot-Slider-Label/blob/master/Media/ReadmeFormat.gif)

### Custom Slider Path

Overrides the default behavior of using the parent. Useful when you want to put the label next to your slider, e.g. in a container.

![](https://github.com/KoBeWi/Godot-Slider-Label/blob/master/Media/ReadmePath.gif)