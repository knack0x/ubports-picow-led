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
				id: listView
				anchors.fill: parent
				model: ListModel {
					id: listViewModel
					ListElement { num: 1 }
					ListElement { num: 2 }
					ListElement { num: 3 }
					ListElement { num: 4 }
					ListElement { num: 5 }
					ListElement { num: 6 }
					ListElement { num: 7 }
					ListElement { num: 8 }
					ListElement { num: 9 }
					ListElement { num: 10 }
					ListElement { num: 11 }
					ListElement { num: 12 }
					ListElement { num: 13 }
					ListElement { num: 14 }
					ListElement { num: 15 }
					ListElement { num: 16 }
					ListElement { num: 17 }
					ListElement { num: 18 }
					ListElement { num: 19 }
					ListElement { num: 20 }
				}
				clip: true

				delegate: ListItem {
					height: itemLayout.height + (divider.visible ? divider.height : 0)

					ListItemLayout {
						id: itemLayout
						title.text: i18n.tr('"Label" ' + model.num + ' inside the "ScrollView"')
					}
				}

				Component.onCompleted: {
					const devices = JSON.parse(goDevices.list())
					for (let d of devices) {
						console.log(`Device: Name=${d.Name}, Host="${d.Host}", Port=${d.Port}`)
						// TODO: Set `listView.model` data
					}
				}
			}
		}
	}
}
