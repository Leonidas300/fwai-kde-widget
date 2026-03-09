import QtQuick
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: configRoot

    property alias cfg_currentUrl: currentUrlField.text
    property alias cfg_pinned: pinnedCheck.checked
    property alias cfg_popupWidth: widthSpin.value
    property alias cfg_hideHeader: hideHeaderCheck.checked
    property alias cfg_avoidMode: avoidModeCheck.checked
    property alias cfg_iconPadding: iconPaddingSpin.value
    property int cfg_currentProviderIndex
    property string cfg_providersJson
    property string cfg_popupPosition
    property string cfg_maximizeShortcut

    property var providers: []

    Component.onCompleted: {
        try {
            providers = JSON.parse(cfg_providersJson)
        } catch(e) {
            providers = [
                { name: "Claude", url: "https://claude.ai", icon: "anthropic" },
                { name: "Grok", url: "https://grok.com", icon: "grok" }
            ]
        }
        providersModel.clear()
        for (var i = 0; i < providers.length; i++) {
            providersModel.append(providers[i])
        }
        refreshDefaultCombo()
    }

    function saveProviders() {
        var arr = []
        for (var i = 0; i < providersModel.count; i++) {
            var item = providersModel.get(i)
            arr.push({ name: item.name, url: item.url, icon: item.icon || "" })
        }
        cfg_providersJson = JSON.stringify(arr)
        refreshDefaultCombo()
    }

    function refreshDefaultCombo() {
        var names = []
        for (var i = 0; i < providersModel.count; i++) {
            names.push(providersModel.get(i).name)
        }
        defaultProviderCombo.model = names
        if (cfg_currentProviderIndex >= providersModel.count) {
            cfg_currentProviderIndex = 0
        }
        defaultProviderCombo.currentIndex = cfg_currentProviderIndex
    }

    ListModel {
        id: providersModel
    }

    Kirigami.FormLayout {
        anchors.left: parent.left
        anchors.right: parent.right

        // ── AI Providers Section ────────────────────────────────
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "AI Providers"
        }

        QQC2.ComboBox {
            id: defaultProviderCombo
            Kirigami.FormData.label: "Default provider:"
            onActivated: function(index) {
                cfg_currentProviderIndex = index
                if (index >= 0 && index < providersModel.count) {
                    cfg_currentUrl = providersModel.get(index).url
                }
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: "Configured providers:"
            Kirigami.FormData.buddyFor: providersList
            Layout.fillWidth: true

            Repeater {
                id: providersList
                model: providersModel

                delegate: RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    // Color dot
                    Rectangle {
                        width: 12
                        height: 12
                        radius: 6
                        color: {
                            if (model.name === "Claude") return "#d4a574"
                            if (model.name === "Grok") return "#1da1f2"
                            return "#007acc"
                        }
                    }

                    // Provider name
                    QQC2.Label {
                        text: model.name
                        Layout.preferredWidth: 100
                    }

                    // Provider URL
                    QQC2.Label {
                        text: model.url
                        Layout.fillWidth: true
                        elide: Text.ElideMiddle
                        opacity: 0.7
                    }

                    // Delete button
                    QQC2.ToolButton {
                        icon.name: "edit-delete"
                        onClicked: {
                            providersModel.remove(index)
                            configRoot.saveProviders()
                        }
                    }
                }
            }

            // Add new provider row
            Kirigami.Separator {
                Layout.fillWidth: true
                Layout.topMargin: 8
            }

            QQC2.Label {
                text: "Add new provider:"
                Layout.topMargin: 4
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                QQC2.TextField {
                    id: newProviderName
                    placeholderText: "Name (e.g. ChatGPT)"
                    Layout.preferredWidth: 140
                }

                QQC2.TextField {
                    id: newProviderUrl
                    placeholderText: "URL (e.g. https://chat.openai.com)"
                    Layout.fillWidth: true
                }

                QQC2.Button {
                    text: "Add"
                    icon.name: "list-add"
                    enabled: newProviderName.text.trim() !== "" && newProviderUrl.text.trim() !== ""
                    onClicked: {
                        providersModel.append({
                            name: newProviderName.text.trim(),
                            url: newProviderUrl.text.trim(),
                            icon: ""
                        })
                        newProviderName.text = ""
                        newProviderUrl.text = ""
                        configRoot.saveProviders()
                    }
                }
            }

            // Quick-add buttons
            QQC2.Label {
                text: "Quick add:"
                Layout.topMargin: 8
            }

            Flow {
                Layout.fillWidth: true
                spacing: 8

                QQC2.Button {
                    text: "Claude (Anthropic)"
                    icon.name: "list-add"
                    onClicked: {
                        providersModel.append({ name: "Claude", url: "https://claude.ai", icon: "anthropic" })
                        configRoot.saveProviders()
                    }
                }
                QQC2.Button {
                    text: "Grok (xAI)"
                    icon.name: "list-add"
                    onClicked: {
                        providersModel.append({ name: "Grok", url: "https://grok.com", icon: "grok" })
                        configRoot.saveProviders()
                    }
                }
                QQC2.Button {
                    text: "ChatGPT"
                    icon.name: "list-add"
                    onClicked: {
                        providersModel.append({ name: "ChatGPT", url: "https://chat.openai.com", icon: "chatgpt" })
                        configRoot.saveProviders()
                    }
                }
                QQC2.Button {
                    text: "Gemini"
                    icon.name: "list-add"
                    onClicked: {
                        providersModel.append({ name: "Gemini", url: "https://gemini.google.com", icon: "google" })
                        configRoot.saveProviders()
                    }
                }
                QQC2.Button {
                    text: "Copilot"
                    icon.name: "list-add"
                    onClicked: {
                        providersModel.append({ name: "Copilot", url: "https://copilot.microsoft.com", icon: "copilot" })
                        configRoot.saveProviders()
                    }
                }
                QQC2.Button {
                    text: "Perplexity"
                    icon.name: "list-add"
                    onClicked: {
                        providersModel.append({ name: "Perplexity", url: "https://www.perplexity.ai", icon: "perplexity" })
                        configRoot.saveProviders()
                    }
                }
                QQC2.Button {
                    text: "DeepSeek"
                    icon.name: "list-add"
                    onClicked: {
                        providersModel.append({ name: "DeepSeek", url: "https://chat.deepseek.com", icon: "deepseek" })
                        configRoot.saveProviders()
                    }
                }
            }
        }

        // ── Behavior Section ────────────────────────────────────
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Behavior"
        }

        QQC2.CheckBox {
            id: avoidModeCheck
            Kirigami.FormData.label: "Avoid mode:"
            text: "Jump to other monitor if non-Dolphin window is open"
        }

        QQC2.CheckBox {
            id: pinnedCheck
            Kirigami.FormData.label: "Keep open:"
            text: "Don't close when clicking outside"
        }

        QQC2.CheckBox {
            id: hideHeaderCheck
            Kirigami.FormData.label: "Hide header:"
            text: "Hide the top toolbar"
        }

        // ── Size Section ────────────────────────────────────────
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Size"
        }

        QQC2.SpinBox {
            id: iconPaddingSpin
            Kirigami.FormData.label: "Panel icon padding:"
            from: 0
            to: 20
            stepSize: 1
        }

        QQC2.Label {
            text: "Extra padding around panel icon (higher = smaller icon)"
            opacity: 0.6
            font.pixelSize: 11
            Layout.leftMargin: 24
        }

        QQC2.SpinBox {
            id: widthSpin
            Kirigami.FormData.label: "Popup width:"
            from: 300
            to: 1920
            stepSize: 10
        }

        // ── Current URL (debug/advanced) ────────────────────────
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: "Advanced"
        }

        QQC2.TextField {
            id: currentUrlField
            Kirigami.FormData.label: "Current URL:"
            Layout.fillWidth: true
        }

    }
}
