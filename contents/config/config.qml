import QtQuick

import org.kde.plasma.configuration

ConfigModel {
    ConfigCategory {
        name: "General"
        icon: "configure"
        source: "configGeneral.qml"
    }
    ConfigCategory {
        name: "Keyboard Shortcuts"
        icon: "preferences-desktop-keyboard"
        source: "configShortcuts.qml"
    }
}
