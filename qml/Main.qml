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

	property var logLines: ""

	function log(message) {
		const newLine = "[" + new Date().toLocaleTimeString() + "] " + message;

		let lines = logLines ? logLines.split("\n\n") : [];

		lines.unshift(newLine);

		if (lines.length > 20) {
			lines.pop();
		}

		logLines = lines.join("\n\n");
	}

	Page {
		anchors.fill: parent

		header: PageHeader {
			id: devicesPageHeader
			title: i18n.tr('PicoW LED')
		}

		ScrollView {
			id: devicesPage

			anchors {
				top: devicesPageHeader.bottom
				left: parent.left
				right: parent.right
				bottom: parent.bottom
			}

			ListView {
				id: devicesList

				anchors {
					margins: units.gu(2)
					top: parent.top
					right: parent.right
					left: parent.left
				}

				property var data: []
				model: data.length

				delegate: ListItem {
					height: deviceListItem.height + units.gu(4) + (divider.visible ? divider.height : 0)

					ListItemLayout {
						id: deviceListItem

						anchors.centerIn: parent

						property var device: devicesList.data[index]

						title.text: `${device.name}`
						title.textSize: Label.Medium
						title.horizontalAlignment: Text.AlignHCenter

						Label {
							id: icon

							SlotsLayout.position: SlotsLayout.Leading
							text: `${deviceListItem.device.icon}`
							textSize: Label.XLarge
						}

						Icon {
							id: powerToggle

							name: "system-shutdown"
							SlotsLayout.position: SlotsLayout.Trailing
							width: units.gu(6)

							color: "#8036454F" // NOTE: Just the initial color

							function setState(v) {
								switch (v) {
									case "ON":
									powerToggle.color = "#00FF00"
									root.log(`Device Color ${deviceListItem.device.name}: #00FF00 (green, state: "ON")`)
									break
									case "OFF":
									powerToggle.color = "#FF0000"
									root.log(`Device Color ${deviceListItem.device.name}: #FF0000 (red, state: "OFF")`)
									break
									case "DISABLED":
									powerToggle.color = "#8036454F"
									// Disabled, this is noise
									//root.log(`Device Color ${deviceListItem.device.name}: #8036454F (charcoal, state: "DISABLED")`)
									break
									case "ERROR":
									powerToggle.color = "#FFA500"
									root.log(`Device Color ${deviceListItem.device.name}: #FFA500 (orange, state: "ERROR")`)
									break
								}
							}

							MouseArea {
								anchors.fill: parent

								property var disabled: false

								onClicked: {
									if (disabled) {
										return
									}

									disabled = true
									powerToggle.setState("DISABLED")

									const device = deviceListItem.device

									try {
										root.log(`Run Power Toggle: ${device.name}`)
										goDevices.powerToggle(device.addr, powerToggle)
									} catch (err) {
										powerToggle.setState("ERROR")
										root.log(`Power Toggle failed: ${device.name}: ${err}`)

									} finally {
										disabled = false
									}
								}
							}
						}
					}
				}

				footer: Column {
					width: devicesList.width

					spacing: units.gu(2)

					Label {
						text: "Log Stream:"
						textSize: Label.XLarge
						color: LomiriColors.ash
					}

					TextArea {
						id: logStream
						anchors.margins: units.gu(2)
						width: parent.width
						wrapMode: Text.WordWrap
						readOnly: true
						autoSize: true
						maximumLineCount: 0

						text: root.logLines

						Component.onCompleted: {
							goDevices.startErrorChannel(root)
						}
					}
				}

				Component.onCompleted: {
					devicesList.data = JSON.parse(goDevices.list()) || []
				}
			}
		}
	}
}
