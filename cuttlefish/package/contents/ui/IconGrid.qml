/***************************************************************************
 *                                                                         *
 *   Copyright 2014-2015 Sebastian Kügler <sebas@kde.org>                  *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 *                                                                         *
 ***************************************************************************/

import QtQuick 2.5
import QtQuick.Controls 2.5 as QQC2
import QtQuick.Layouts 1.0

import org.kde.kirigami 2.8 as Kirigami

GridView {
    id: iconGrid
    focus: true

    cellWidth: iconSize + Math.round(Kirigami.Units.gridUnit * 1.5)
    cellHeight: cellWidth + Math.round(Kirigami.Units.gridUnit * 2)

    cacheBuffer: 20
    highlightMoveDuration: 0
    boundsBehavior: Flickable.StopAtBounds
    model: iconModel

    highlight: Item {}

    delegate: IconGridDelegate {}

    QQC2.BusyIndicator {
        running: iconModel.loading
        visible: running
        anchors.centerIn: parent
        width: Kirigami.Units.gridUnit * 8
        height: width
    }
}
