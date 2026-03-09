import QtQuick
import QtQuick.Layouts 1.1
import QtQuick.Window
import QtWebEngine
import org.kde.plasma.plasmoid 2.0
import org.kde.kirigami 2.20 as Kirigami
import org.kde.taskmanager as TaskManager

PlasmoidItem {
    id: root

    // Shared WebEngine profile (cookies shared between main view and auth popup)
    WebEngineProfile {
        id: mainWebProfile
        //httpUserAgent: "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.0.0 Safari/537.36"
        httpUserAgent: "Mozilla/5.0 (Windows NT 11.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.6998.166 Safari/537.36"
        storageName: "fwai-widget"
        offTheRecord: false
        httpCacheType: WebEngineProfile.DiskHttpCache
        persistentCookiesPolicy: WebEngineProfile.ForcePersistentCookies
    }

    property var providers: {
        try {
            return JSON.parse(plasmoid.configuration.providersJson)
        } catch(e) {
            return [
                { name: "Claude", url: "https://claude.ai", icon: "anthropic" },
                { name: "Grok", url: "https://grok.com", icon: "grok" }
            ]
        }
    }

    property int currentIndex: plasmoid.configuration.currentProviderIndex
    property bool maximized: false
    property bool sideWindowVisible: false

    switchWidth: Kirigami.Units.gridUnit * 10
    switchHeight: Kirigami.Units.gridUnit * 10

    compactRepresentation: CompactRepresentation {}

    fullRepresentation: FullRepresentation {
        Layout.preferredWidth: root.maximized ? Screen.width : plasmoid.configuration.popupWidth
        Layout.preferredHeight: Screen.desktopAvailableHeight
        Layout.minimumWidth: Kirigami.Units.gridUnit * 20
        Layout.minimumHeight: Kirigami.Units.gridUnit * 30
    }

    preferredRepresentation: compactRepresentation

    toolTipMainText: {
        if (root.providers.length === 0) return "AI Widget"
        return root.providers[root.currentIndex]?.name || "AI Widget"
    }
    toolTipSubText: ""

    Binding {
        target: root
        property: "hideOnWindowDeactivate"
        value: !plasmoid.configuration.pinned
        restoreMode: Binding.RestoreBinding
    }

    // ── TaskManager model for avoid mode (works on both X11 and Wayland) ──
    TaskManager.TasksModel {
        id: tasksModel
        sortMode: TaskManager.TasksModel.SortDisabled
        groupMode: TaskManager.TasksModel.GroupDisabled
    }

    // Count non-excluded, non-minimized windows on the WIDGET's screen only
    function countBlockingWindows() {
        var excludePatterns = ["dolphin", "pulpit", "plasmashell", "krunner", "kded", "kwin", "xwaylandvideobridge", "freewill"]
        var myScreenX = Screen.virtualX
        var myScreenW = Screen.width
        var count = 0
        for (var i = 0; i < tasksModel.count; i++) {
            var idx = tasksModel.index(i, 0)
            var isWindow = tasksModel.data(idx, TaskManager.AbstractTasksModel.IsWindow)
            if (!isWindow) continue
            var isMinimized = tasksModel.data(idx, TaskManager.AbstractTasksModel.IsMinimized)
            if (isMinimized) continue

            // Only count windows on the widget's screen
            var geom = tasksModel.data(idx, TaskManager.AbstractTasksModel.Geometry)
            if (geom) {
                var winCenterX = geom.x + geom.width / 2
                if (winCenterX < myScreenX || winCenterX >= myScreenX + myScreenW)
                    continue
            }

            var appName = (tasksModel.data(idx, TaskManager.AbstractTasksModel.AppName) || "").toString().toLowerCase()
            var title = (tasksModel.data(idx, Qt.DisplayRole) || "").toString().toLowerCase()
            var excluded = false
            for (var j = 0; j < excludePatterns.length; j++) {
                if (appName.indexOf(excludePatterns[j]) !== -1 || title.indexOf(excludePatterns[j]) !== -1) {
                    excluded = true
                    break
                }
            }
            if (!excluded) count++
        }
        return count
    }

    function switchProvider(index) {
        if (index >= 0 && index < providers.length) {
            currentIndex = index
            plasmoid.configuration.currentProviderIndex = index
            plasmoid.configuration.currentUrl = providers[index].url
        }
    }

    function nextProvider() {
        var next = (currentIndex + 1) % providers.length
        switchProvider(next)
    }

    function previousProvider() {
        var prev = (currentIndex - 1 + providers.length) % providers.length
        switchProvider(prev)
    }

    function toggleMaximized() {
        maximized = !maximized
        if (sideWindowVisible) {
            positionSideWindow(sideWindow.avoidActive)
        } else if (maximized && root.expanded) {
            _avoidRedirecting = true
            root.expanded = false
            _avoidRedirecting = false
            positionSideWindow(false)
        }
    }

    // ── Main click handler ──────────────────────────────────────────
    function handleWidgetClick() {
        if (sideWindowVisible) {
            sideWindow.hide()
            sideWindowVisible = false
            return
        }

        if (plasmoid.configuration.avoidMode) {
            var hasBlocking = countBlockingWindows() > 0
            positionSideWindow(hasBlocking)
        } else {
            positionSideWindow(false)
        }
    }

    // ── Position and show the side window ────────────────────────────
    function positionSideWindow(useOtherScreen) {
        var screenX = Screen.virtualX
        var screenW = Screen.width
        var screenH = Screen.height
        var screenY = Screen.virtualY

        // Calculate panel/taskbar height
        var panelH = screenH - Screen.desktopAvailableHeight
        if (panelH < 0 || panelH > 100) panelH = 0

        if (useOtherScreen) {
            var totalW = Screen.desktopAvailableWidth
            if (screenX === 0) {
                screenX = screenW
                screenW = totalW - screenW
            } else {
                screenW = screenX
                screenX = 0
            }
        }

        var w = maximized ? screenW : Math.min(plasmoid.configuration.popupWidth, screenW)
        var h = screenH - panelH

        sideWindow.x = screenX + screenW - w
        sideWindow.y = screenY
        sideWindow.width = w
        sideWindow.height = h
        sideWindow.avoidActive = useOtherScreen
        sideWindow.show()
        sideWindow.raise()
        sideWindow.requestActivate()
        sideWindowVisible = true
    }

    // ── Side Window ─────────────────────────────────────────────────
    Window {
        id: sideWindow
        visible: false
        flags: Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint | Qt.Tool
        color: "#1e1e1e"

        property bool avoidActive: false

        FullRepresentation {
            anchors.fill: parent
        }

        onVisibleChanged: {
            if (!visible) {
                sideWindowVisible = false
            }
        }

        // Close when clicking outside (if not pinned)
        onActiveChanged: {
            if (!active && visible && !plasmoid.configuration.pinned) {
                sideWindow.hide()
                sideWindowVisible = false
            }
        }

        // Close on Escape
        Item {
            focus: true
            Keys.onEscapePressed: {
                sideWindow.hide()
            }
        }
    }



    // Intercept expanded changes (from global shortcut) → always use sideWindow
    property bool _avoidRedirecting: false
    onExpandedChanged: {
        if (_avoidRedirecting) return

        if (expanded) {
            // Always redirect to sideWindow
            _avoidRedirecting = true
            root.expanded = false
            _avoidRedirecting = false

            if (sideWindowVisible) {
                // Already open → close
                sideWindow.hide()
                sideWindowVisible = false
            } else {
                if (plasmoid.configuration.avoidMode) {
                    var hasBlocking = countBlockingWindows() > 0
                    positionSideWindow(hasBlocking)
                } else {
                    positionSideWindow(false)
                }
            }
        }
    }
}
