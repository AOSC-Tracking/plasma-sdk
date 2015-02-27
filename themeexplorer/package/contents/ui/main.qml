/*
 *   Copyright 2015 Marco Martin <mart@kde.org>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2 or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Controls 1.3
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore

ApplicationWindow {
    id: root
    width: units.gridUnit * 50
    height: units.gridUnit * 35
    visible: true
    property int iconSize: iconSizeSlider.value
    property alias showMargins: showMarginsCheckBox.checked

    toolBar: ToolBar {
        RowLayout {
            anchors.fill: parent
            Label {
                text: i18n("Theme:")
            }
            ComboBox {
                id: themeSelector
                //FIXME: why crashes?
                //model: 3//themeModel.themeList
                textRole: "packageNameRole"
                onCurrentIndexChanged: {
                    themeModel.theme = themeModel.themeList.get(currentIndex).packageNameRole;
                }
            }
            CheckBox {
                id: showMarginsCheckBox
                text: i18n("Show Margins")
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            TextField {
                placeholderText: i18n("Search...")
                onTextChanged: searchModel.filterRegExp = ".*" + text + ".*"
            }
        }
    }

    Timer {
        running: true
        interval: 200
        onTriggered: {
            themeSelector.model = themeModel.themeList
        }
    }
    SystemPalette {
        id: palette
    }

    Rectangle {
        anchors.fill: scrollView
        color: theme.viewBackgroundColor
    }
    ScrollView {
        id: scrollView
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            right: sidebar.left
        }
        GridView {
            id: view
            anchors.fill: parent
            model: PlasmaCore.SortFilterModel {
                id: searchModel
                sourceModel: themeModel
                filterRole: "imagePath"
            }
            cellWidth: root.iconSize
            cellHeight: cellWidth
            highlightMoveDuration: 0

            highlight: Rectangle {
                radius: 3
                color: palette.highlight
            }
            delegate: MouseArea {
                width: view.cellWidth
                height: view.cellHeight
                property QtObject modelData: model
                onClicked: {
                    view.currentIndex = index;
                }
                Loader {
                    z: -1
                    anchors.fill: parent
                    source: Qt.resolvedUrl("delegates/" + model.delegate + ".qml")
                }
                Rectangle {
                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        margins: units.gridUnit
                    }
                    width: units.gridUnit
                    height: units.gridUnit
                    radius: units.gridUnit
                    opacity: 0.5
                    color: model.usesFallback ? "red" : "green"
                }
            }
        }
    }
    Item {
        id: sidebar
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
        }
        width: root.width / 3
        ColumnLayout {
            anchors {
                fill: parent
                margins: units.gridUnit
            }
            Label {
                Layout.fillWidth: true
                text: i18n("Preview:")
            }
            Loader {
                id: extendedLoader
                property QtObject model: view.currentItem.modelData
                Layout.fillWidth: true
                Layout.minimumHeight: width
                source: Qt.resolvedUrl("delegates/" + model.delegate + ".qml")
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
            Label {
                Layout.fillWidth: true
                text: i18n("Image path: %1", view.currentItem.modelData.imagePath)
                wrapMode: Text.WordWrap
            }
            Label {
                Layout.fillWidth: true
                text: i18n("Description: %1", view.currentItem.modelData.description)
                wrapMode: Text.WordWrap
            }
            Label {
                Layout.fillWidth: true
                text: view.currentItem.modelData.usesFallback ? i18n("Missing from this theme") : i18n("Present in this theme")
                wrapMode: Text.WordWrap
            }
            Button {
                text: view.currentItem.modelData.usesFallback ? i18n("Create with Editor...") : i18n("Open In Editor...")
                enabled: view.currentItem.modelData.isWritable
                Layout.alignment: Qt.AlignHCenter
                onClicked: {
                    print(view.currentItem.modelData.svgAbsolutePath)
                    Qt.openUrlExternally(view.currentItem.modelData.svgAbsolutePath)
                }
            }
            Slider {
                id: iconSizeSlider
                Layout.fillWidth: true
                value: units.gridUnit * 12
                minimumValue: units.gridUnit * 5
                maximumValue: units.gridUnit * 20
            }
        }
    }
}
