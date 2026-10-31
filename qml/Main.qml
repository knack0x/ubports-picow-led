import QtQuick 2.12
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
			id: devicesPageHeader
			title: i18n.tr('PicoW LED')
		}

		ScrollView {
			anchors {
				margins: units.gu(2)
				top: devicesPageHeader.bottom
				right: parent.right
				bottom: parent.bottom
				left: parent.left
			}

			ListView {
				id: deviceListView
				anchors.fill: parent

				clip: true

				model: 0
				property var devices: []

				delegate: ListItem {
					height: deviceListItemLayout.height + (divider.visible ? divider.height : 0)

					ListItemLayout {
						id: deviceListItemLayout
						title.text: i18n.tr(`${deviceListView.devices[index].Name} - ${deviceListView.devices[index].Host}:${deviceListView.devices[index].Port}`)
					}
				}

				Component.onCompleted: {
					deviceListView.devices = JSON.parse(goDevices.list()) || []
					deviceListView.model = deviceListView.devices.length
				}
			}
		}
	}
}
