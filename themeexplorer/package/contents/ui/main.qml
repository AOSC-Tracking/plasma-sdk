/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 1.3
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15

import org.kde.kirigami 2.19 as Kirigami

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras

Kirigami.ApplicationWindow {
    id: root

    property int iconSize: iconSizeSlider.value
    property alias showMargins: showMarginsCheckBox.checked

    width: Kirigami.Units.gridUnit * 50
    height: Kirigami.Units.gridUnit * 35
    visible: true

    Shortcut {
        sequence: StandardKey.Quit
        onActivated: Qt.quit()
    }

    header: QQC2.ToolBar {
        RowLayout {
            anchors.fill: parent
            QQC2.ToolButton {
                text: i18n("New Theme…")
                icon.name: "document-new"
                onClicked: {
                    if (!root.metadataEditor) {
                        root.metadataEditor = metadataEditorComponent.createObject(root);
                    }
                    root.metadataEditor.newTheme = true;
                    root.metadataEditor.name = "";
                    root.metadataEditor.author = "";
                    root.metadataEditor.email = "";
                    root.metadataEditor.license = "LGPL 2.1+";
                    root.metadataEditor.website = "";
                    root.metadataEditor.open();
                }
            }
            QQC2.Label {
                text: i18n("Theme:")
            }
            QQC2.ComboBox {
                id: themeSelector
                model: themeModel.themeList

                textRole: "display"
                valueRole: "packageNameRole"

                Component.onCompleted: {
                    currentIndex = indexOfValue(commandlineTheme)
                }

                onActivated: {
                    themeModel.theme = currentValue;
                }
            }
            QQC2.ToolButton {
                text: i18n("Open Folder")
                icon.name: "document-open-folder"
                onClicked: Qt.openUrlExternally(themeModel.themeFolder);
            }
            QQC2.ToolButton {
                text: i18n("Edit Metadata…")
                icon.name: "configure"
                enabled: view.currentItem.modelData.isWritable
                onClicked: {
                    if (!root.metadataEditor) {
                        root.metadataEditor = metadataEditorComponent.createObject(root);
                    }
                    root.metadataEditor.newTheme = false;
                    root.metadataEditor.name = themeModel.theme;
                    root.metadataEditor.author = themeModel.author;
                    root.metadataEditor.email = themeModel.email;
                    root.metadataEditor.license = themeModel.license;
                    root.metadataEditor.website = themeModel.website;
                    root.metadataEditor.open();
                }
            }
            QQC2.ToolButton {
                text: i18n("Edit Colors…")
                icon.name: "color"
                enabled: view.currentItem.modelData.isWritable
                onClicked: {
                    if (!root.colorEditor) {
                        root.colorEditor = colorEditorComponent.createObject(root);
                    }

                    root.colorEditor.open();
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            QQC2.ToolButton {
                text: i18n("Help")
                icon.name: "help-contents"
                onClicked: Qt.openUrlExternally("https://techbase.kde.org/Development/Tutorials/Plasma5/ThemeDetails");
            }
            Kirigami.SearchField {
                placeholderText: i18n("Search…")
                onTextEdited: searchModel.setFilterFixedString(text)
            }
        }
    }

    property QtObject metadataEditor
    Component {
        id: metadataEditorComponent
        MetadataEditor {
            onCreated: name => {
                themeSelector.currentIndex = themeSelector.indexOfValue(name);
            }
        }
    }
    property QtObject colorEditor
    Component {
        id: colorEditorComponent
        ColorEditor {}
    }

    QQC2.SplitView {
        anchors.fill: parent

        QQC2.ScrollView {
            id: scroll

            QQC2.SplitView.fillHeight: true
            QQC2.SplitView.fillWidth: true

            // HACK: workaround for https://bugreports.qt.io/browse/QTBUG-83890
            QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

            QQC2.ScrollBar.vertical.policy: QQC2.ScrollBar.AlwaysOn

            background: Rectangle {
                color: theme.viewBackgroundColor
            }
            GridView {
                id: view

                QtObject {
                    id: internal
                    readonly property int availableWidth: scroll.width - internal.scrollBarSpace - Kirigami.Units.smallSpacing
                    readonly property int scrollBarSpace: scroll.QQC2.ScrollBar.vertical.width
                }

                anchors {
                    fill: parent
                    margins: Kirigami.Units.smallSpacing / 2
                }

                clip: true
                activeFocusOnTab: true

                property int implicitCellWidth: root.iconSize
                property int implicitCellHeight: root.iconSize

                cellWidth: Math.floor(internal.availableWidth / Math.floor(internal.availableWidth / implicitCellWidth))
                cellHeight: implicitCellHeight

                model: PlasmaCore.SortFilterModel {
                    id: searchModel
                    sourceModel: themeModel
                    filterRole: "imagePath"
                }
                highlightMoveDuration: 0
                highlight: PlasmaExtras.Highlight {}

                Loader {
                    anchors.centerIn: parent
                    width: parent.width - (Kirigami.Units.gridUnit * 4)
                    active: false
                    opacity: view.count === 0 ? 1 : 0
                    Behavior on opacity {
                        id: behaviorScroll
                        SequentialAnimation {
                            PropertyAction {
                                target: behaviorScroll.targetProperty.object
                                property: 'active'
                                value: true
                            }
                            OpacityAnimator {
                                duration: Kirigami.Units.longDuration
                                easing.type: Easing.InOutQuad
                            }
                            PropertyAction {
                                target: behaviorScroll.targetProperty.object
                                property: 'active'
                                value: behaviorScroll.targetValue > 0
                            }
                        }
                    }
                    sourceComponent: Kirigami.PlaceholderMessage {
                        width: parent.width
                        icon.name: "edit-none"
                        text: i18nc("A search yielded no results", "No items matching your search")
                    }
                }

                delegate: Item {
                    property QtObject modelData: model

                    width: GridView.view.cellWidth
                    height: GridView.view.cellHeight

                    MouseArea {
                        z: 2
                        anchors.fill: parent
                        onClicked: {
                            view.currentIndex = index;
                        }
                    }
                    Loader {
                        id: delegate
                        z: -1
                        width: Math.min(parent.width, parent.height)
                        height: width
                        anchors.centerIn: parent

                        source: Qt.resolvedUrl("delegates/" + model.delegate + ".qml")
                    }
                    PresenceIndicator {
                        z: 3
                        anchors {
                            right: delegate.right
                            bottom: delegate.bottom
                            margins: Kirigami.Units.gridUnit
                        }
                        usesFallback: model.usesFallback
                    }
                }
            }
        }

        QQC2.Pane {
            id: sidebar

            QQC2.SplitView.fillHeight: true
            QQC2.SplitView.fillWidth: true
            QQC2.SplitView.preferredWidth: QQC2.SplitView.view.width / 3

            padding: 0

            Loader {
                id: placeholderSideBar
                anchors.centerIn: parent
                z: 1
                width: parent.width - (Kirigami.Units.gridUnit * 4)
                active: false
                opacity: view.currentIndex === -1 ? 1 : 0
                Behavior on opacity {
                    id: behaviorSidebar
                    SequentialAnimation {
                        PropertyAction {
                            target: behaviorSidebar.targetProperty.object
                            property: 'active'
                            value: true
                        }
                        OpacityAnimator {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                        PropertyAction {
                            target: behaviorSidebar.targetProperty.object
                            property: 'active'
                            value: behaviorSidebar.targetValue > 0
                        }
                    }
                }
                sourceComponent: Kirigami.PlaceholderMessage {
                    width: parent.width
                    text: i18n("Select an image on the left to see its properties here")
                }
            }

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                opacity: view.currentIndex === -1 ? 0 : 1
                Behavior on opacity {
                    OpacityAnimator {
                        duration: Kirigami.Units.longDuration
                        easing.type: Easing.InOutQuad
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: false
                    Layout.margins: Kirigami.Units.largeSpacing
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.Label {
                        Layout.fillWidth: true
                        visible: !view.currentItem.modelData.isWritable
                        text: i18n("This is a readonly, system wide installed theme.")
                        wrapMode: Text.WordWrap
                    }
                    QQC2.Label {
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: i18n("Preview:")
                    }
                    Loader {
                        id: extendedLoader
                        property QtObject model: view.currentItem.modelData
                        Layout.fillWidth: true
                        Layout.minimumHeight: width
                        source: Qt.resolvedUrl("delegates/" + model.delegate + ".qml")
                    }

                    Kirigami.Separator {
                        Layout.fillWidth: true
                    }
                }

                QQC2.ScrollView {
                    id: sidebarScroll

                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    // HACK: workaround for https://bugreports.qt.io/browse/QTBUG-83890
                    QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

                    contentWidth: availableWidth

                    QQC2.Pane {
                        width: sidebarScroll.availableWidth
                        background: null

                        contentItem: ColumnLayout {
                            spacing: Kirigami.Units.smallSpacing

                            QQC2.Label {
                                Layout.fillWidth: true
                                text: i18n("<b>Image path:</b> %1", view.currentItem.modelData.imagePath)
                                wrapMode: Text.WordWrap
                            }
                            QQC2.Label {
                                Layout.fillWidth: true
                                text: i18n("<b>Description:</b> %1", view.currentItem.modelData.description)
                                wrapMode: Text.WordWrap
                            }
                            PresenceIndicator {
                                Layout.fillWidth: true
                                usesFallback: view.currentItem.modelData.usesFallback
                                mode: PresenceIndicator.Mode.Full
                            }
                            QQC2.CheckBox {
                                id: showMarginsCheckBox
                                text: i18n("Show Margins")
                            }
                            QQC2.Button {
                                text: view.currentItem.modelData.usesFallback ? i18n("Create with Editor…") : i18n("Open In Editor…")
                                enabled: view.currentItem.modelData.isWritable
                                Layout.alignment: Qt.AlignHCenter
                                onClicked: {
                                    print(view.currentItem.modelData.svgAbsolutePath)
                                    themeModel.editElement(view.currentItem.modelData.imagePath)
                                    //Qt.openUrlExternally(view.currentItem.modelData.svgAbsolutePath)
                                }
                            }
                            QQC2.Slider {
                                id: iconSizeSlider
                                Layout.fillWidth: true
                                value: Kirigami.Units.gridUnit * 12
                                from: Kirigami.Units.gridUnit * 5
                                to: Kirigami.Units.gridUnit * 20
                            }
                        }
                    }
                }
            }
        }
    }
}
