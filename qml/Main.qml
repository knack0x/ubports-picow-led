import QtQuick 2.7
import Lomiri.Components 1.3
//import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'picow-led.knack0x'

    width: units.gu(45)
    height: units.gu(75)

    Page {
        anchors.fill: parent

        header: PageHeader {
            id: header
            title: i18n.tr('PicoW LED')
        }

        Label {
            anchors.centerIn: parent
            text: i18n.tr('Check the logs!')
        }
    }

    ColumnLayout {
        spacing: units.gu(2)
        anchors {
            margins: units.gu(2)
            top: header.bottom
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        Item {
            Layout.fillHeight: true
        }

        Label {
            text: testvar.message
            horizontalAlignment: Label.AlignHCenter
            Layout.fillWidth: true

            /*
                To export go functions they have to be in uppercase but in qml
                the first letter of the function has to be lower case.
                The qml<->go bridge takes care of that.
            */
        }

        Label {
            text: testvar.output
            horizontalAlignment: Label.AlignHCenter
            Layout.fillWidth: true
        }

        Button {
            text: 'Do it!'
            color: 'green'
            onClicked: testvar.getMessage()
            Layout.alignment: Qt.AlignCenter
        }

        Item {
            Layout.fillHeight: true
        }
    }
}
