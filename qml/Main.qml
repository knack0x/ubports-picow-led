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

				ListItemLayout {
					id: deviceListItemLayout

					title.text: `${devicesListView.devices[index].Name.split(" ").slice(1).join(" ")}`
					title.textSize: Label.Medium
					title.horizontalAlignment: Text.AlignHCenter

					Label {
						SlotsLayout.position: SlotsLayout.Leading
						text: `${devicesListView.devices[index].Name.split(" ")[0]}`
						textSize: Label.XLarge
					}

					Icon {
						name: "system-shutdown"
						SlotsLayout.position: SlotsLayout.Trailing
						width: units.gu(4)
						color: "#FF0000"

						MouseArea {
							anchors.fill: parent
							// TODO: disable button while processing the power toggle, only enable after server responds. (error == orange, on == green, off == red)
							onClicked: {
								console.log("-> power toggle button clicked")
							}
						}
					}
				}
			}

			Component.onCompleted: {
				devicesListView.devices = JSON.parse(goDevices.list()) || []
				devicesListView.model = devicesListView.devices.length
			}
		}
	}
}
