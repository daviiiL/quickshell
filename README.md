# daviiiL's latest quickshell

material-vertical uses razer-cli and openrazer to match the theme colorscheme with your device rgbs... so install both beforehand if you want that

some UI modules and service singletons need extra system pacakges to function; without them, the shell might not display some UI modules

## TODO

- [ ] Polish services
- [x] Polish lockscreen ui (hiding component and a pixel shifting clock to save my oled monitors)
- [x] Add power management window
- [x] Add a control center window (network, bluetooth, settings, etc) 
- [ ] Add a frontend for openai

## Known Bugs 

- [x] FIXED: when changing colorscheme from the control center, the wallpaper picker still holds onto the initial value loaded from Preferences... even after preferences.colorscheme has changed...
