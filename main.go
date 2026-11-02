package main

import (
	"encoding/json"
	"fmt"
	"log"

	picow_models "github.com/knackwurstking/picow-led/pkg/models"
	"github.com/knackwurstking/picow-led/pkg/picow"
	"github.com/nanu-c/qml-go"
)

const (
	PicowServer = "192.168.178.52:50835" // Format <host:port>
)

var (
	devices *Devices = NewDevices(
		Device{Host: "192.168.178.50", Port: 3000, Name: "📺 Wohnzimmer"},
		Device{Host: "192.168.178.68", Port: 3000, Name: "💻 Schreibtisch"},
		Device{Host: "192.168.178.62", Port: 3000, Name: "🚽 Badezimmer"},
		Device{Host: "192.168.178.67", Port: 3000, Name: "🛌 Schlafzimmer"},
		Device{Host: "192.168.178.54", Port: 3000, Name: "✂️ Arbeitszimmer"},
	)

	ColorOFF   = picow_models.NewColor("off", [3]uint8{0, 0, 0}, 0, 0)
	ColorWhite = picow_models.NewColor("white", [3]uint8{255, 255, 255}, 255, 255)
)

func main() {
	err := qml.Run(run)
	if err != nil {
		log.Fatal(err)
	}
}

func run() error {
	engine := qml.NewEngine()
	component, err := engine.LoadFile("qml/Main.qml")
	if err != nil {
		return err
	}

	context := engine.Context()
	context.SetVar("goDevices", devices)

	win := component.CreateWindow(context)

	win.Show()
	win.Wait()

	return nil
}

func NewJSON(v any) string {
	data, err := json.Marshal(v) // TODO: print error to stderr and return empty
	if err != nil {
		panic(err)
	}
	return string(data)
}

type Device struct {
	Host string
	Port int
	Name string
}

type Devices struct {
	data []Device
}

func NewDevices(d ...Device) *Devices {
	return &Devices{
		data: d,
	}
}

func (d *Devices) List() string {
	return NewJSON(d.data)
}

// PowerToggle does switch lights per device on an off
//
// NOTE: The error return is string typed because this struct is set to QML
func (d *Devices) PowerToggle(deviceHost string) (err string) {
	device := d.get(deviceHost)

	if duty, err := picow.GetDuty(device); err != nil {
		for _, n := range duty {
			if n > 0 { // Yes.. The light is on fire :)
				err = picow.SetDuty(device, ColorWhite.GetDuty(device.Type)...) // NOTE: For now, just set white
				if err != nil {
					return err.Error()
				}
			}
		}

		err = picow.SetDuty(device, ColorOFF.GetDuty(device.Type)...)
		if err != nil {
			return err.Error()
		}
	} else {
		return fmt.Sprintf("Failed to retrieve duty for \"%s\" (%s): %s", deviceHost, device.Addr, err.Error())
	}

	return ""
}

// get ist private because i am not sure if `*picow_models.Device` return does work with QML (this `struct` ist set for QML)
func (d *Devices) get(host string) *picow_models.Device {
	for _, device := range d.data {
		if device.Host == host {
			return picow_models.NewDevice(fmt.Sprintf("%s:%d", device.Host, device.Port), device.Name, picow_models.DeviceTypeRGBW)
		}
	}
	return nil
}
