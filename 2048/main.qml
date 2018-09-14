import QtQuick 2.6
import QtQuick.Window 2.2

Window {
    id: windowShow
    visible: true
    title: qsTr("2048")
    color: "#bbada0"
    width: columnTotal * 100
    height: rowTotal * 100
    property variant existRectArray: []
    property int columnTotal: 4
    property int rowTotal: 4
    Item {
        id: insideShow
        anchors.fill: parent

        ListModel {
            id: rectmode
        }

        Grid {
            id: mainboard
            x: 5
            y: 5
            spacing: 10
            Repeater {
                id: mainboardRepeater
                model: columnTotal * rowTotal
                Rectangle {
                    color: "#cdc0b4"
                    width: windowShow.width / columnTotal - mainboard.spacing
                    height: windowShow.height / rowTotal - mainboard.spacing
                    radius: 5
                    property int col : index % columnTotal
                    property int row : index / rowTotal
                }
            }
        }

        Component {
            id: singleRectComponent
            Rectangle {
                id: singleRect
                property int singleColumn: 0
                property int singleRow: 0
                property int numInside: Math.random() > 0.9 ? 4 : 2
                color: numInside <=    1 ? "transparent" :
                       numInside <=    2 ? "#eee4da" :
                       numInside <=    4 ? "#ede0c8" :
                       numInside <=    8 ? "#f2b179" :
                       numInside <=   16 ? "#f59563" :
                       numInside <=   32 ? "#f67c5f" :
                       numInside <=   64 ? "#f65e3b" :
                       numInside <=  128 ? "#edcf72" :
                       numInside <=  256 ? "#edcc61" :
                       numInside <=  512 ? "#edc850" :
                       numInside <= 1024 ? "#edc53f" :
                       numInside <= 2048 ? "#edc22e" :
                                        "#3c3a32"

                function moveOneRect(col,row) {
                    if (col == singleColumn && row == singleRow)
                        return false
                    if (existRectParam(col, row)) {
                        numInside += existRectParam(col, row).numInside
                        popNumberAt(col, row)
                    }
                    singleColumn = col
                    singleRow = row
                    return true
                }
                x: getCurItem(singleColumn,singleRow).x + 5
                y: getCurItem(singleColumn,singleRow).y + 5
                width: windowShow.width / columnTotal - mainboard.spacing
                height: windowShow.height / rowTotal - mainboard.spacing
                radius: getCurItem(singleColumn,singleRow).radius
                Text {
                    id: singleRectText
                    anchors.centerIn: parent
                    text: numInside
                    font.pixelSize: 70
                    font.bold: true
                    color: numInside <= 4 ? "black":"white"
                }
                transform: Scale {
                    id: zoomIn
                    origin.x: singleRect.width / 2
                    origin.y: singleRect.height / 2
                    xScale: 0
                    yScale: 0
                    Behavior on xScale {
                        NumberAnimation {
                            duration: 200
                            easing {
                                type: Easing.InOutQuad
                            }
                        }
                    }
                    Behavior on yScale {
                        NumberAnimation {
                            duration: 200
                            easing {
                                type: Easing.InOutQuad
                            }
                        }
                    }
                }
                Behavior on x {
                    NumberAnimation {
                        duration: 200
                        easing {
                            type: Easing.InOutQuad
                        }
                    }
                }
                Behavior on y {
                    NumberAnimation {
                        duration: 200
                        easing {
                            type: Easing.InOutQuad
                        }
                    }
                }
                Component.onCompleted: {
                    zoomIn.xScale = 1
                    zoomIn.yScale = 1
                }
            }
        }

        Keys.forwardTo: parent
        focus: true
        Keys.onPressed: {
            switch(event.key) {
            case Qt.Key_Left:
                moveBoard(0);
                break;
            case Qt.Key_Right:
                moveBoard(1);
                break;
            case Qt.Key_Up:
                moveBoard(2);
                break;
            case Qt.Key_Down:
                moveBoard(3);
                break;
            case Qt.Key_Space:
                clearBoard();
                randomAddOnce();
                randomAddOnce();
                break;
            default:
                return;
            }
            event.accepted = true
        }
    }
    property bool somethingMoved: false
    onSomethingMovedChanged: {
        if(somethingMoved){
            addItem.running = true
        }
    }
    Timer {
        id: addItem
        running: false
        repeat: false
        interval: 200
        onTriggered: {
            randomAddOnce();
        }
    }

    function moveBoard(positionTmp) {
        var columnsTmp = positionTmp & 1
        var rowsTmp =(positionTmp >>1) & 1
        somethingMoved = false

        switch (positionTmp){
        case 0:
            for (var j = 0; j < rowTotal; j++) {
                var filled = 0
                var canMerge = false
                for (var i = 0; i < columnTotal; i++) {
                    if (existRectParam(i,j)) {
                        if (canMerge) {
                            if (existRectParam(i,j).numInside == existRectParam(filled-1,j).numInside) {
                                canMerge = false
                                filled--
                            }
                        }
                        else {
                            canMerge = true
                        }
                        if (existRectParam(i,j).moveOneRect(filled,j))
                            somethingMoved = true
                        filled++
                    }
                }
            }
            break;
        case 1:
            for (var j = 0; j < rowTotal; j++) {
                var filled = 0
                var canMerge = false
                for (var i = columnTotal - 1; i >= 0; i--) {
                    if (existRectParam(i,j)) {
                        if (canMerge) {
                            if (existRectParam(i,j).numInside == existRectParam(columnTotal - filled,j).numInside) {
                                canMerge = false
                                filled--
                            }
                        }
                        else {
                            canMerge = true
                        }
                        if (existRectParam(i,j).moveOneRect(columnTotal - 1 -filled,j))
                            somethingMoved = true
                        filled++
                    }
                }
            }
            break;
        case 2:
            for (var i = 0;i <columnTotal;i++) {
                var filled = 0
                var canMerge = false
                for (var j = 0;j < rowTotal;j++){
                    if(existRectParam(i,j)) {
                        if(canMerge) {
                            if(existRectParam(i,j).numInside == existRectParam(i,filled-1).numInside) {
                                canMerge = false
                                filled--
                            }
                        } else {
                            canMerge = true
                        }
                        if (existRectParam(i,j).moveOneRect(i,filled))
                            somethingMoved = true
                        filled++
                    }
                }
            }

            break;
        case 3:
            for (var i = 0; i < columnTotal; i++) {
                var filled = 0
                var canMerge = false
                for (var j = rowTotal - 1; j >= 0; j--) {
                    if (existRectParam(i,j)) {
                        if (canMerge) {
                            if (existRectParam(i,j).numInside == existRectParam(i,rowTotal - filled).numInside) {
                                canMerge = false
                                filled--
                            }
                        }
                        else {
                            canMerge = true
                        }
                        if (existRectParam(i,j).moveOneRect(i,rowTotal - 1 -filled))
                            somethingMoved = true
                        filled++
                    }
                }
            }
            break;
        default:
            break;
        }

        somethingMoved = true
    }

    function clearBoard() {
        for (var i = 0;i < existRectArray.length;i++){
            existRectArray[i].destroy()
        }
        existRectArray = [];
    }

    function randomAddOnce() {
        var randomRectobj = getRandomEmptyobj();
        if (existRectArray.length < 16) {
            existRectArray.push(singleRectComponent.createObject(insideShow,{"singleColumn":randomRectobj.col,"singleRow":randomRectobj.row}))
        }
    }

    function getRandomEmptyobj() {
        var tmparray = new Array();
        for (var i = 0;i < columnTotal;i++){
            for (var j = 0;j < rowTotal;j++){
                if (!existRectParam(i, j)) {
                    tmparray.push(getCurItem(i, j))
                }
            }
        }
        return tmparray[Math.floor(Math.random() * tmparray.length)]
    }

    function existRectParam(col, row) {
        for (var k = 0; k < existRectArray.length; k++) {
            if (existRectArray[k].singleColumn == col && existRectArray[k].singleRow == row)
                return existRectArray[k]
        }
    }

    function getCurItem(col, row) {
        return mainboardRepeater.itemAt( col + row * 4)
    }

    function removeOneParam(col, row) {
        for (var i = 0;i < existRectArray.length ;i++){
            if (existRectArray[i].singleColumn == col && existRectArray[i].singleRow == row){
                existRectArray[i].destroy()
                existRectArray.splice(i,1)
            }
        }

    }

    function popNumberAt(col, row) {
        var tmp = existRectArray
        for (var i = 0; i < tmp.length; i++) {
            if (tmp[i].singleColumn == col && tmp[i].singleRow == row) {
                tmp[i].destroy()
                tmp.splice(i, 1)
            }
        }
        existRectArray=tmp
    }
    Component.onCompleted: {
        clearBoard();
        randomAddOnce();
        randomAddOnce();
    }
}
