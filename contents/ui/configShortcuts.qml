import QtQuick
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: shortcutsRoot

    property alias cfg_maximizeShortcut: maximizeShortcutField.text

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        QQC2.TextField {
            id: maximizeShortcutField
            Kirigami.FormData.label: "Maximize shortcut:"
            placeholderText: "e.g. F11, Ctrl+M, Alt+F"
            Layout.preferredWidth: 200
        }

        QQC2.Label {
            text: "Format: modifiers + key, e.g. Ctrl+Shift+M, F11, Alt+Z"
            opacity: 0.6
            font.pixelSize: 11
            Layout.leftMargin: 24
        }

        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Built-in Shortcuts"
        }

        QQC2.Label {
            Kirigami.FormData.label: "Widget shortcuts:"
            text: "Ctrl+Tab / Ctrl+Shift+Tab - Switch AI\nF5 / Ctrl+R - Refresh\nEscape - Close side window"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        QQC2.Label {
            Kirigami.FormData.label: "Global shortcut:"
            text: "System Settings > Shortcuts > Shortcuts > FWAI"
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
            opacity: 0.7
        }
    }
}
