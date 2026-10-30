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

		ScrollView {
			anchors {
				margins: units.gu(2)
				top: header.bottom
				right: parent.right
				bottom: parent.bottom
				left: parent.left
			}

			ListView {
				anchors.fill: parent
				model: ["1", "2", "3", "4", "5"]
				clip: true

				delegate: Label {
					fontSize: "medium"
					text: i18n.tr('"Label" ' + modelData + ' inside the "ScrollView"')
				}
			}
		}
	}
}
