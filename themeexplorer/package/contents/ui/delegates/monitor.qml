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
    PlasmaCore.Svg {
        id: monitorSvg
        imagePath: "widgets/monitor"
    }
    PlasmaCore.SvgItem {
        anchors {
            horizontalCenter: parent.horizontalCenter
            top: screen.bottom
            topMargin: -Kirigami.Units.gridUnit
        }
        svg: monitorSvg
        elementId: "base"
    }
    PlasmaCore.FrameSvgItem {
        id: screen
        anchors {
            left: background.left
            top: background.top
            right: background.right
            margins: Kirigami.Units.gridUnit
        }
        height: width / 1.6
        imagePath: "widgets/monitor"

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

    PlasmaComponents.Label {
        anchors {
            horizontalCenter: background.horizontalCenter
            bottom: background.bottom
        }
        text: model.imagePath
        visible: width < background.width
    }
}
