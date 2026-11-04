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

	// TODO: Add a Log stream component somehow (dead simple at first)
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
							color: "#FF0000"

							Timer {
								id: resetPowerToggleColor
								interval: 500
								repeat: false
								onTriggered: {
									// TODO: Get the device power state and set color accordingly (ON = green, OFF = red)
									powerToggle.color = "#FF0000"
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

									// TODO: Need a better color for this (alpha 80 is OK)
									powerToggle.color = "#80FF0000" // Disable Color

									const device = deviceListItem.device

									try {
										console.log(`--> Power Toggle: ${device.Name} ${device.Host}:${device.Port}`)
										goDevices.powerToggle(device.Host)
									} catch (err) {
										console.log(`[ERROR] Toggle power for "${device.Name}" failed; ${err}`)
										powerToggle.color = "#FFA500" // Error Color
										// TODO: Render error message to the log component
									} finally {
										disabled = false
										resetPowerToggleColor.stop() // Cancel a running timer (if running)
										resetPowerToggleColor.start()
									}
								}
							}
						}
					}
				}

				footer: Item {
					width: devicesList.widht
					height: contentHeight

					Label {
						anchors.margins: units.gu(2)
						text: "Log Stream:\nLine 1...\nLine 2...\n"
					}
				}

				Component.onCompleted: {
					devicesList.data = JSON.parse(goDevices.list()) || []
				}
			}
		}
	}
}
