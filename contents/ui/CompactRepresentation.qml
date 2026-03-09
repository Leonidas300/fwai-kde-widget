import QtQuick
import QtQuick.Layouts
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami

MouseArea {
    id: compactRoot

    hoverEnabled: true
    acceptedButtons: Qt.LeftButton

    onClicked: {
        root.handleWidgetClick()
    }

    Image {
        id: icon
        anchors.fill: parent
        anchors.margins: 1 + (plasmoid.configuration.iconPadding || 0)
        source: Qt.resolvedUrl("../../icon.png")
        sourceSize.width: 128
        sourceSize.height: 128
        smooth: true
        mipmap: true
        antialiasing: true
        fillMode: Image.PreserveAspectFit
        opacity: compactRoot.containsMouse ? 1.0 : 0.85

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }
    }

    states: [
        State {
            name: "hovered"
            when: compactRoot.containsMouse
            PropertyChanges {
                target: icon
                scale: 1.1
            }
        }
    ]
}
