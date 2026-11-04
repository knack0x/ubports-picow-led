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

						title.text: `${device.Name.split(" ").slice(1).join(" ")}`
						title.textSize: Label.Medium
						title.horizontalAlignment: Text.AlignHCenter

						Label {
							SlotsLayout.position: SlotsLayout.Leading
							text: `${deviceListItem.device.Name.split(" ")[0]}`
							textSize: Label.XLarge
						}

						Icon {
							id: powerToggle

							name: "system-shutdown"
							SlotsLayout.position: SlotsLayout.Trailing
							width: units.gu(6)

							function setState(v) {
								switch (v) {
									case "ON":
									powerToggle.color = "#00FF00"
									break
									case "OFF":
									powerToggle.color = "#FF0000"
									break
									case "DISABLED":
									powerToggle.color = "#8036454F"
									break
									case "ERROR":
									powerToggle.color = "#FFA500"
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
										console.log(`--> Power Toggle: ${device.Name} ${device.Host}:${device.Port}`)
										goDevices.powerToggle(device.Host, powerToggle)
									} catch (err) {
										powerToggle.setState("ERROR")
										console.log(`[ERROR] ${message}`)
										logStream.append(message)

									} finally {
										disabled = false
									}
								}
							}

							Component.onCompleted: {
								powerToggle.setState("DISABLED") // NOTE: Yes, this initial "DISABLED" color is on purpose.. Currently there is no initial color check, so i do not know if the lights is ON/OFF
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

						property var logLines: []

						function append(message) {
							logLines.unshift("[" + new Date().toLocaleTimeString() + "] " + message)

							if (logLines.length > 20) {
								logLines.pop()
							}

							text = logLines.join("\n")
						}

						Component.onCompleted: {
							append("Log Stream is initialized and ready to go 😏")
							goDevices.startErrorChannel(logStream)
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
