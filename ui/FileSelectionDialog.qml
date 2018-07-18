import QtQuick 2.0
import Sailfish.Silica 1.0
import SailfishUiSet 1.0

Dialog {
    id: dialogRoot

    property int maximumSelections : 1
    property var filesToSelect : [];
    property string remotePath : "";
    property int __numSelect : 0
    property string acceptText : header.defaultAcceptText
    property string cancelText : header.defaultCancelText

    canAccept: __numSelect > 0;

    LocalFileBrowser {
        id: fileBrowser
    }
    FileDetailsHelper {
        id: fileDetailsHelper
    }

    NumberAnimation {
        id: outAnimation
        target: listView
        property: "opacity"
        duration: 100
        easing.type: Easing.InOutQuad
        from: 1.0
        to: 0.0
        running: false

        onStopped: {
            listView.model = fileBrowser.cd(fileBrowser.path);
            inAnimation.start()
        }
    }

    NumberAnimation {
        id: inAnimation
        target: listView
        property: "opacity"
        duration: 100
        easing.type: Easing.OutInQuad
        from: 0.0
        to: 1.0
        running: false

        onStopped: {
            listView.enabled = true;
        }
    }

    SilicaFlickable {
        anchors.fill: parent

        DialogHeader {
            id: header
            acceptText: dialogRoot.acceptText
            cancelText: dialogRoot.cancelText
        }

        SilicaListView {
            id: listView
            clip: true
            y: header.y + header.height
            width: parent.width
            height: parent.height - y
            model: fileBrowser.cd()

            delegate: BackgroundItem {
                id: delegate

                Rectangle {
                    id: highlighting
                    color: Theme.highlightColor
                    visible: filesToSelect.indexOf(listView.model[index].path) >= 0;
                    anchors.fill: parent
                    opacity: 0.5
                }

                Image {
                    id: icon
                    source: listView.model[index].isDirectory ?
                                (listView.model[index].name !== ".." ?
                                    "image://theme/icon-m-folder" :
                                    "image://theme/icon-m-back"
                                 ) :
                                fileDetailsHelper.getIconFromMime(listView.model[index].mimeType)
                    anchors.left: parent.left
                    anchors.leftMargin: Theme.paddingLarge
                    anchors.top: parent.top
                    anchors.topMargin: 18
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 18
                    height: label.height
                    fillMode: Image.PreserveAspectFit
                }

                Label {
                    id: label
                    x: icon.x + icon.width + 12
                    y: icon.y - icon.height + 6
                    visible: listView.model[index].name !== ".."
                    text: listView.model[index].name
                    anchors.verticalCenter: parent.verticalCenter
                    color: delegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                }

                onClicked: {
                    var tmpPath = listView.model[index].path;
                    if (listView.model[index].isDirectory) {
                        fileBrowser.path = tmpPath;
                        listView.enabled = false;
                        outAnimation.start()
                    } else { // isFile
                        var selectionIndex = filesToSelect.indexOf(tmpPath);
                        if (selectionIndex >= 0) {
                            filesToSelect.splice(selectionIndex, 1);
                        } else if (filesToSelect.length < maximumSelections){
                            filesToSelect.push(tmpPath);
                        }
                        highlighting.visible = filesToSelect.indexOf(tmpPath) >= 0;
                        __numSelect = filesToSelect.length;
                    }
                }
            }
        }
    }
}
