/*
 *   SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *   SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.3

import org.kde.kirigami 2.19 as Kirigami

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: delegateRoot
    property var prefixes: model.frameSvgPrefixes
    property var imagePath: model.imagePath
    Rectangle {
        id: background
        anchors {
            fill: parent
            margins: Kirigami.Units.gridUnit
        }
        radius: 3
        color: theme.backgroundColor
        opacity: 0.6
    }
    Flow {
        id: flow
        clip: true
        anchors {
            fill: parent
            margins: Kirigami.Units.gridUnit * 2
        }
        Repeater {
            model: delegateRoot.prefixes
            delegate: PlasmaCore.FrameSvgItem {
                width: flow.width / 2
                height: flow.height / 3
                imagePath: delegateRoot.imagePath
                prefix: modelData
                PlasmaComponents.Label {
                    anchors.centerIn: parent
                    text: modelData
                    visible: width < parent.width
                }

                Rectangle {
                    id: marginsRectangle
                    anchors {
                        fill: parent
                        leftMargin: parent.margins.left
                        topMargin: parent.margins.top
                        rightMargin: parent.margins.right
                        bottomMargin: parent.margins.bottom
                    }
                    color: "green"
                    opacity: 0.5
                    visible: root.showMargins
                }
            }
        }
    }

    PlasmaComponents.Label {
        anchors {
            horizontalCenter: background.horizontalCenter
            bottom: background.bottom
        }
        text: model.imagePath
        visible: width < flow.width
    }
}
