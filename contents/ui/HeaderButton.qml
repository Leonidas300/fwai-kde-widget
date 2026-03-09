import QtQuick
import org.kde.kirigami 2.20 as Kirigami

Rectangle {
    id: headerBtn

    property string iconText: ""
    property string iconName: ""
    property string tooltipText: ""
    property bool isActive: false

    signal btnClicked()

    width: 30
    height: 30
    radius: 6
    color: btnMouse.containsMouse ? "#404040" : (isActive ? "#37373d" : "transparent")

    Kirigami.Icon {
        anchors.centerIn: parent
        width: 16
        height: 16
        source: iconName
        visible: iconName !== ""
        color: isActive ? "#007acc" : (btnMouse.containsMouse ? "#cccccc" : "#858585")
    }

    Text {
        anchors.centerIn: parent
        text: iconText
        visible: iconName === ""
        color: isActive ? "#007acc" : (btnMouse.containsMouse ? "#cccccc" : "#858585")
        font.pixelSize: 15
    }

    MouseArea {
        id: btnMouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: headerBtn.btnClicked()
    }

    Rectangle {
        id: tooltip
        visible: btnMouse.containsMouse && tooltipText !== ""
        anchors.top: parent.bottom
        anchors.topMargin: 4
        anchors.horizontalCenter: parent.horizontalCenter
        width: tooltipLabel.implicitWidth + 16
        height: 26
        radius: 4
        color: "#252526"
        border.color: "#3c3c3c"
        border.width: 1
        z: 200

        Text {
            id: tooltipLabel
            anchors.centerIn: parent
            text: tooltipText
            color: "#cccccc"
            font.pixelSize: 11
        }
    }
}
