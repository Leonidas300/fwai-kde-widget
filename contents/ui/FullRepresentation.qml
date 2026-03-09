import QtQuick
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.15 as QQC2
import QtWebEngine
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.20 as Kirigami

// VS Code Dark Theme Colors
// Background:  #1e1e1e
// Sidebar:     #252526
// Titlebar:    #323233
// Border:      #3c3c3c
// Text:        #cccccc
// TextDim:     #858585
// Accent:      #007acc
// Hover:       #2a2d2e
// InputBg:     #3c3c3c
// ButtonHover: #404040

Item {
    id: fullRoot

    // ── Top Header Bar ──────────────────────────────────────────────────
    Rectangle {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: plasmoid.configuration.hideHeader ? 0 : 42
        visible: !plasmoid.configuration.hideHeader
        color: "#323233"
        z: 10

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8
            spacing: 4

            // AI Provider Selector (left side)
            Rectangle {
                id: providerButton
                Layout.preferredHeight: 30
                Layout.preferredWidth: providerRow.implicitWidth + 20
                color: providerMouse.containsMouse ? "#404040" : "transparent"
                radius: 6

                MouseArea {
                    id: providerMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: providerPopup.visible = !providerPopup.visible
                }

                Row {
                    id: providerRow
                    anchors.centerIn: parent
                    spacing: 6

                    // Provider icon (colored dot)
                    Rectangle {
                        width: 14
                        height: 14
                        radius: 7
                        anchors.verticalCenter: parent.verticalCenter
                        color: {
                            if (root.providers.length === 0) return "#007acc"
                            var name = root.providers[root.currentIndex]?.name || ""
                            if (name === "Claude") return "#d4a574"
                            if (name === "Grok") return "#1da1f2"
                            return "#007acc"
                        }
                    }

                    Text {
                        text: {
                            if (root.providers.length === 0) return "No AI"
                            return root.providers[root.currentIndex]?.name || "Select AI"
                        }
                        color: "#cccccc"
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: "\u25BE" // down triangle
                        color: "#858585"
                        font.pixelSize: 10
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                // Provider Dropdown Popup
                Rectangle {
                    id: providerPopup
                    visible: false
                    anchors.top: parent.bottom
                    anchors.topMargin: 4
                    anchors.left: parent.left
                    width: 200
                    height: providerColumn.implicitHeight + 16
                    color: "#252526"
                    border.color: "#3c3c3c"
                    border.width: 1
                    radius: 8
                    z: 100

                    // Shadow
                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: -1
                        color: "transparent"
                        border.color: "#00000040"
                        border.width: 1
                        radius: 9
                        z: -1
                    }

                    Column {
                        id: providerColumn
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: 8
                        spacing: 2

                        Repeater {
                            model: root.providers.length

                            Rectangle {
                                width: providerColumn.width
                                height: 34
                                radius: 4
                                color: providerItemMouse.containsMouse ? "#2a2d2e" : (index === root.currentIndex ? "#37373d" : "transparent")

                                MouseArea {
                                    id: providerItemMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        root.switchProvider(index)
                                        providerPopup.visible = false
                                    }
                                }

                                Row {
                                    anchors.left: parent.left
                                    anchors.leftMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    spacing: 8

                                    Rectangle {
                                        width: 10
                                        height: 10
                                        radius: 5
                                        anchors.verticalCenter: parent.verticalCenter
                                        color: {
                                            var name = root.providers[index]?.name || ""
                                            if (name === "Claude") return "#d4a574"
                                            if (name === "Grok") return "#1da1f2"
                                            return "#007acc"
                                        }
                                    }

                                    Text {
                                        text: root.providers[index]?.name || ""
                                        color: index === root.currentIndex ? "#ffffff" : "#cccccc"
                                        font.pixelSize: 13
                                        anchors.verticalCenter: parent.verticalCenter
                                    }
                                }

                                // Checkmark for active
                                Text {
                                    visible: index === root.currentIndex
                                    anchors.right: parent.right
                                    anchors.rightMargin: 10
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "\u2713"
                                    color: "#007acc"
                                    font.pixelSize: 14
                                }
                            }
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            // ── Action Buttons (right side) ─────────────────────────
            // New Chat
            HeaderButton {
                iconName: "document-new"
                tooltipText: "New Chat"
                onBtnClicked: {
                    webview.url = plasmoid.configuration.currentUrl
                }
            }

            // Refresh
            HeaderButton {
                iconName: "view-refresh"
                tooltipText: "Refresh"
                onBtnClicked: {
                    webview.reload()
                }
            }

            // Avoid mode toggle
            HeaderButton {
                iconName: "window-duplicate"
                tooltipText: plasmoid.configuration.avoidMode ? "Avoid: ON (jump to other monitor)" : "Avoid: OFF"
                isActive: plasmoid.configuration.avoidMode
                onBtnClicked: {
                    plasmoid.configuration.avoidMode = !plasmoid.configuration.avoidMode
                }
            }

            // Maximize
            HeaderButton {
                iconName: root.maximized ? "window-restore" : "window-maximize"
                tooltipText: root.maximized ? "Restore Size" : "Maximize"
                isActive: root.maximized
                onBtnClicked: {
                    root.toggleMaximized()
                }
            }

            // Pin / Keep Open
            HeaderButton {
                iconName: "window-pin"
                tooltipText: plasmoid.configuration.pinned ? "Unpin" : "Pin (Keep Open)"
                isActive: plasmoid.configuration.pinned
                onBtnClicked: {
                    plasmoid.configuration.pinned = !plasmoid.configuration.pinned
                }
            }

            // Settings
            HeaderButton {
                iconName: "configure"
                tooltipText: "Settings"
                onBtnClicked: {
                    plasmoid.internalAction("configure").trigger()
                }
            }
        }
    }

    // Close dropdown when clicking outside
    MouseArea {
        anchors.fill: parent
        visible: providerPopup.visible
        z: 5
        onClicked: providerPopup.visible = false
    }

    // ── WebEngine View ──────────────────────────────────────────────────
    WebEngineView {
        id: webview
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        z: 1

        url: plasmoid.configuration.currentUrl

        profile: mainWebProfile
        settings.javascriptCanAccessClipboard: true
        settings.javascriptCanOpenWindows: true

        onLoadingChanged: function(loadingInfo) {
            if (loadingInfo.status === WebEngineView.LoadSucceededStatus) {
                webview.runJavaScript("
                    if (!document.getElementById('fwai-dark-scroll')) {
                        var style = document.createElement('style');
                        style.id = 'fwai-dark-scroll';
                        style.textContent = '::-webkit-scrollbar{width:8px}::-webkit-scrollbar-track{background:#1e1e1e}::-webkit-scrollbar-thumb{background:#424242;border-radius:4px}::-webkit-scrollbar-thumb:hover{background:#555}';
                        document.head.appendChild(style);
                    }
                ")
            }
        }

        // Handle popups (OAuth, etc.) - load directly in webview
        onNewWindowRequested: function(request) {
            webview.url = request.requestedUrl
        }

        onContextMenuRequested: function(request) {
            if (request.mediaType === ContextMenuRequest.MediaTypeNone && request.linkUrl.toString() !== "") {
                linkMenu.linkUrl = request.linkUrl
                linkMenu.open(request.position.x, request.position.y)
                request.accepted = true
            }
        }

        onNavigationRequested: function(request) {
            if (request.navigationType === WebEngineNavigationRequest.NavigationTypeLinkClicked) {
                if (request.url.toString().indexOf(getDomain(plasmoid.configuration.currentUrl)) === -1) {
                    Qt.openUrlExternally(request.url)
                    request.action = WebEngineNavigationRequest.IgnoreRequest
                }
            }
        }

        // Loading indicator
        Rectangle {
            id: loadingBar
            anchors.top: parent.top
            anchors.left: parent.left
            height: 2
            width: parent.width * (webview.loadProgress / 100.0)
            color: "#007acc"
            visible: webview.loading
            opacity: webview.loading ? 1.0 : 0.0

            Behavior on width {
                NumberAnimation { duration: 200 }
            }
            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
        }
    }

    // Link context menu
    PlasmaExtras.Menu {
        id: linkMenu
        visualParent: webview

        property url linkUrl

        PlasmaExtras.MenuItem {
            text: "Open Link in Browser"
            icon: "internet-web-browser"
            onClicked: Qt.openUrlExternally(linkMenu.linkUrl)
        }

        PlasmaExtras.MenuItem {
            text: "Copy Link"
            icon: "edit-copy"
            onClicked: webview.triggerWebAction(WebEngineView.CopyLinkToClipboard)
        }
    }

    // Mouse area for back/forward buttons
    MouseArea {
        id: navMouseArea
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        acceptedButtons: Qt.BackButton | Qt.ForwardButton
        z: 0

        onPressed: function(mouse) {
            if (mouse.button === Qt.BackButton) {
                webview.goBack()
            } else if (mouse.button === Qt.ForwardButton) {
                webview.goForward()
            }
        }
    }

    // ── Keyboard Shortcuts ──────────────────────────────────────────────

    // Parse configured shortcut into key + modifiers
    property var maximizeBinding: parseShortcut(plasmoid.configuration.maximizeShortcut)

    function parseShortcut(str) {
        if (!str) return { key: Qt.Key_F11, modifiers: Qt.NoModifier }
        var parts = str.toUpperCase().split("+")
        var mods = Qt.NoModifier
        var keyStr = parts[parts.length - 1].trim()

        for (var i = 0; i < parts.length - 1; i++) {
            var m = parts[i].trim()
            if (m === "CTRL" || m === "CONTROL") mods |= Qt.ControlModifier
            else if (m === "ALT") mods |= Qt.AltModifier
            else if (m === "SHIFT") mods |= Qt.ShiftModifier
            else if (m === "META" || m === "SUPER") mods |= Qt.MetaModifier
        }

        var keyMap = {
            "F1": Qt.Key_F1, "F2": Qt.Key_F2, "F3": Qt.Key_F3, "F4": Qt.Key_F4,
            "F5": Qt.Key_F5, "F6": Qt.Key_F6, "F7": Qt.Key_F7, "F8": Qt.Key_F8,
            "F9": Qt.Key_F9, "F10": Qt.Key_F10, "F11": Qt.Key_F11, "F12": Qt.Key_F12,
            "ESCAPE": Qt.Key_Escape, "ESC": Qt.Key_Escape,
            "RETURN": Qt.Key_Return, "ENTER": Qt.Key_Return,
            "SPACE": Qt.Key_Space, "TAB": Qt.Key_Tab,
            "A": Qt.Key_A, "B": Qt.Key_B, "C": Qt.Key_C, "D": Qt.Key_D,
            "E": Qt.Key_E, "F": Qt.Key_F, "G": Qt.Key_G, "H": Qt.Key_H,
            "I": Qt.Key_I, "J": Qt.Key_J, "K": Qt.Key_K, "L": Qt.Key_L,
            "M": Qt.Key_M, "N": Qt.Key_N, "O": Qt.Key_O, "P": Qt.Key_P,
            "Q": Qt.Key_Q, "R": Qt.Key_R, "S": Qt.Key_S, "T": Qt.Key_T,
            "U": Qt.Key_U, "V": Qt.Key_V, "W": Qt.Key_W, "X": Qt.Key_X,
            "Y": Qt.Key_Y, "Z": Qt.Key_Z,
            "0": Qt.Key_0, "1": Qt.Key_1, "2": Qt.Key_2, "3": Qt.Key_3,
            "4": Qt.Key_4, "5": Qt.Key_5, "6": Qt.Key_6, "7": Qt.Key_7,
            "8": Qt.Key_8, "9": Qt.Key_9
        }

        return { key: keyMap[keyStr] || Qt.Key_F11, modifiers: mods }
    }

    Keys.onPressed: function(event) {
        // Ctrl+Tab - next AI
        if (event.key === Qt.Key_Tab && (event.modifiers & Qt.ControlModifier)) {
            root.nextProvider()
            event.accepted = true
        }
        // Ctrl+Shift+Tab - previous AI
        if (event.key === Qt.Key_Backtab && (event.modifiers & Qt.ControlModifier)) {
            root.previousProvider()
            event.accepted = true
        }
        // F5 - refresh
        if (event.key === Qt.Key_F5) {
            webview.reload()
            event.accepted = true
        }
        // Ctrl+R - refresh
        if (event.key === Qt.Key_R && (event.modifiers & Qt.ControlModifier)) {
            webview.reload()
            event.accepted = true
        }
        // Configurable maximize shortcut
        if (event.key === maximizeBinding.key && (event.modifiers & maximizeBinding.modifiers) === maximizeBinding.modifiers) {
            root.toggleMaximized()
            event.accepted = true
        }
    }

    focus: true

    // Watch for provider changes
    Connections {
        target: plasmoid.configuration
        function onCurrentUrlChanged() {
            webview.url = plasmoid.configuration.currentUrl
        }
    }

    // Background fill
    Rectangle {
        anchors.fill: parent
        color: "#1e1e1e"
        z: -1
    }

    function getDomain(urlStr) {
        try {
            var a = urlStr.toString()
            var start = a.indexOf("://")
            if (start === -1) return a
            var domain = a.substring(start + 3)
            var end = domain.indexOf("/")
            if (end !== -1) domain = domain.substring(0, end)
            return domain
        } catch(e) {
            return ""
        }
    }
}
