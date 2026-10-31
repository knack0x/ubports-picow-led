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

		ListView {
			id: devicesListView

			anchors {
				margins: units.gu(2)
				top: devicesPageHeader.bottom
				right: parent.right
				left: parent.left
				bottom: parent.bottom
			}

			property var devices: []

			delegate: ListItem {
				height: deviceListItemLayout.height + (divider.visible ? divider.height : 0)

				// TODO: Power toggle (button - right aligned), color change (right action), separate icon to the left (big and centered), name centered between the power toggle and the icon, below this a host:port line (small text, only if possible with this component, no magic)
				ListItemLayout {
					id: deviceListItemLayout
					title.text: `${devicesListView.devices[index].Name} - ${devicesListView.devices[index].Host}:${devicesListView.devices[index].Port}`
				}
			}

			Component.onCompleted: {
				devicesListView.devices = JSON.parse(goDevices.list()) || []
				devicesListView.model = devicesListView.devices.length
			}
		}
	}
}
