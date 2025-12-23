//@ pragma UseQApplication
//@ pragma IconTheme breeze-dark

import QtQuick
import Quickshell
import qs.modules

import qs.services

ShellRoot {

    property var todotest: Todo.todoFilePath

    StatusBar {}
    Osd {}
    Bar {}
    Sidebar {}
    ScreenCorners {}
    Cheatsheet {}
    Lockscreen {}
    NotificationPopup {}
}
