# Quickshell Widget Library

A collection of reusable QML widgets and components for Quickshell projects, featuring Material Design 3 theming and a fully-functional application launcher.

## Overview

This library provides:
- **Generic styled widgets** - Buttons, sliders, text fields, progress bars, and more
- **Application launcher** - Full-featured app launcher with fuzzy search
- **Theming system** - Material Design 3 color scheme support with automatic dark/light mode
- **Utilities** - String manipulation, file operations, and fuzzy search

## Structure

```
quickshell/
├── shell.qml                       # Example usage
├── colors.json                     # Material Design 3 color scheme
├── modules/
│   └── AppLauncherPanel.qml       # Application launcher panel
├── components/
│   └── applauncher/               # App launcher UI components
├── services/
│   ├── AppLauncher.qml            # App launcher service
│   ├── AppSearch.qml              # Fuzzy search service
│   └── Preferences.qml            # Dark mode preferences
├── widgets/                        # Generic styled widgets
│   ├── MaterialSymbol.qml         # Material Symbol icons
│   ├── StyledButton.qml           # Styled button component
│   ├── StyledRadioButton.qml      # Radio button
│   ├── StyledProgressBar.qml      # Progress bar
│   ├── StyledSlider.qml           # Slider component
│   ├── StyledText.qml             # Styled text
│   ├── StyledTextField.qml        # Text input field
│   ├── StyledIndicatorButton.qml  # Toggle button with indicator
│   ├── StyledSwitchButton.qml     # Switch toggle
│   ├── StyledListView.qml         # List view
│   ├── StyledImage.qml            # Image component
│   ├── RectWidgetCard.qml         # Card container
│   └── MaterialCookie.qml         # Material-styled cookie component
└── common/                         # Shared utilities
    ├── Colors.qml                  # Color system
    ├── Theme.qml                   # Theme constants
    ├── GlobalStates.qml            # Global state management
    ├── StringUtils.qml             # String utilities
    ├── FileUtils.qml               # File operations
    ├── Fuzzy.qml                   # Fuzzy search
    └── fuzzysort.js                # Fuzzy sort algorithm
```

## Available Widgets

### Buttons

**StyledButton** - Standard button with icon and text
```qml
import qs.widgets

StyledButton {
    icon: "settings"
    text: "Settings"
    highlighted: true
    onClicked: console.log("Button clicked")
}
```

**StyledIndicatorButton** - Toggle button with visual indicator
```qml
StyledIndicatorButton {
    checked: wifiEnabled
    buttonIcon: "wifi"
    buttonText: "WiFi"
    onClicked: toggleWifi()
}
```

**StyledSwitchButton** - Switch-style toggle
```qml
StyledSwitchButton {
    checked: darkMode
    onClicked: darkMode = !darkMode
}
```

**StyledRadioButton** - Radio button with custom styling
```qml
StyledRadioButton {
    checked: currentOption === "option1"
    text: "Option 1"
    onClicked: currentOption = "option1"
}
```

### Input Components

**StyledTextField** - Text input field
```qml
StyledTextField {
    placeholderText: "Enter text..."
    onTextChanged: handleInput(text)
}
```

**StyledSlider** - Slider component
```qml
StyledSlider {
    value: volume
    from: 0
    to: 100
    onValueChanged: setVolume(value)
}
```

### Display Components

**StyledText** - Styled text component
```qml
StyledText {
    text: "Hello World"
    font.pixelSize: Theme.font.size.lg
    color: Colors.on_surface
}
```

**StyledProgressBar** - Progress indicator
```qml
StyledProgressBar {
    value: 0.75  // 0.0 to 1.0
    highlightColor: Colors.primary
}
```

**RectWidgetCard** - Container card with optional title
```qml
RectWidgetCard {
    showTitle: true
    title: "Card Title"
    contentBackground: Colors.surface

    // Your content here
    ColumnLayout {
        Text { text: "Card content" }
    }
}
```

### Icons

**MaterialSymbol** - Material Symbol icons
```qml
MaterialSymbol {
    icon: "search"
    iconSize: Theme.font.size.xl
    fontColor: Colors.primary
}
```

## Application Launcher

The included application launcher provides fuzzy search functionality for installed applications.

### Usage

```qml
import Quickshell
import qs.modules

ShellRoot {
    AppLauncherPanel {}
}
```

The launcher can be triggered by setting `GlobalStates.appLauncherOpen = true`:

```qml
import qs.common

// Open the launcher
GlobalStates.appLauncherOpen = true

// Close the launcher
GlobalStates.appLauncherOpen = false
```

### Features

- Fuzzy search across application names
- Highlighted search matches
- Keyboard navigation
- Icon display for applications
- Execute applications with Enter key
- Terminal application support

## Theming

### Color Scheme

The library uses Material Design 3 color schemes defined in `colors.json`. This file can be generated using [Matugen](https://github.com/InioX/matugen) or created manually.

### Theme Constants

Access theme constants via the `Theme` singleton:

```qml
import qs.common

Rectangle {
    radius: Theme.ui.radius.md
    color: Colors.surface

    Text {
        font.family: Theme.font.family.inter
        font.pixelSize: Theme.font.size.lg
    }
}
```

Available theme properties:
- `Theme.font.size.*` - Font sizes (xs, sm, md, lg, xl, xxl)
- `Theme.font.family.*` - Font families
- `Theme.ui.radius.*` - Border radii (sm, md, lg)
- `Theme.ui.padding.*` - Padding sizes
- `Theme.anim.durations.*` - Animation durations
- `Theme.anim.curves.*` - Animation easing curves

### Colors

Access colors via the `Colors` singleton:

```qml
import qs.common

Rectangle {
    color: Colors.surface
    border.color: Colors.outline

    Text {
        color: Colors.on_surface
    }
}
```

Common colors:
- `Colors.primary`, `Colors.secondary`, `Colors.tertiary`
- `Colors.surface`, `Colors.background`
- `Colors.error`, `Colors.success`, `Colors.warning`
- `Colors.on_primary`, `Colors.on_surface`, etc.

### Dark Mode

Toggle dark mode via Preferences:

```qml
import qs.services

// Set dark mode
Preferences.setDarkMode(true)

// Check current mode
if (Preferences.darkMode) {
    // Dark mode is active
}
```

## Utilities

### StringUtils

```qml
import qs.common

// Escape HTML
StringUtils.escapeHtml("<script>alert('xss')</script>")

// Shell escape for single quotes
StringUtils.shellSingleQuoteEscape("user's input")
```

### FileUtils

```qml
import qs.common

// File operations
FileUtils.readFile("/path/to/file")
FileUtils.writeFile("/path/to/file", "content")
```

### Fuzzy Search

```qml
import qs.common

// Perform fuzzy search
const results = Fuzzy.search("query", itemList, {
    key: "name",
    threshold: 0.6
})
```

## Example: Custom Panel

```qml
import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import qs.common
import qs.widgets

PanelWindow {
    anchors {
        top: true
        left: true
        right: true
    }

    height: 40
    color: Colors.surface

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "custom:panel"

    RowLayout {
        anchors.fill: parent
        anchors.margins: Theme.ui.padding.sm

        StyledButton {
            icon: "apps"
            text: "Apps"
            onClicked: GlobalStates.appLauncherOpen = true
        }

        Item { Layout.fillWidth: true }

        StyledText {
            text: Qt.formatTime(new Date(), "hh:mm")
            font.pixelSize: Theme.font.size.md
        }
    }
}
```

## Dependencies

- [Quickshell](https://quickshell.outfoxxed.me/) - Required Qt-based shell framework
- Material Design Icons font (optional, for MaterialSymbol component)

## Integration

To use this library in your Quickshell project:

1. Copy the relevant directories (`widgets/`, `common/`, etc.) to your project
2. Import components using the appropriate module paths
3. Customize `colors.json` for your color scheme
4. Adjust `Theme.qml` constants as needed

## License

This is a personal widget library. Check individual components for licensing information.
