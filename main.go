package main

import (
	"encoding/json"
	"fmt"
	"log"
	"os"

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
	data, err := json.Marshal(v)
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

// Devices QML handler for devices
//
// NOTE: Always use the `NewDevices` function for initializing this. It will make the error channel which is a private field.
type Devices struct {
	data []Device

	errChannel chan error
	_errChannelStop chan error
	_errChannelRunning bool
}

func NewDevices(d ...Device) *Devices {
	return &Devices{
		data:       d,
	}
}

func (d *Devices) List() string {
	return NewJSON(d.data)
}

func (d *Devices) StartErrorChannel(obj qml.Object) {
	if d._errChannelRunning {
		return // Already running
	}
	d._errChannelRunning = true

	d.errChannel = make(chan error, 1)
	d._errChannelStop = make(chan error, 1)

	go func() {
		defer func() {
			d._errChannelRunning = false
			close(d.errChannel)
			close(d._errChannelStop)
		}()

		for true {
			select {
			case err := <- d.errChannel:
				if obj == nil {
					fmt.Fprintf(os.Stderr, "[ERROR] %v\n", err)
				} else {
					// TODO: Error notify (or something else) for the UI.
				}
			case <- d._errChannelStop:
				return
			}
		}
	}()
}

// PowerToggle does switch lights per device on an off
func (d *Devices) PowerToggle(deviceHost string) {
	d.StartErrorChannel(nil)

	go func() {
		device := d.get(deviceHost)
		if device == nil {
			d.errChannel <- fmt.Errorf("Failed to retrieve device \"%s\"", deviceHost)
			return
		}

		if duty, err := picow.GetDuty(device); err == nil {
			for _, n := range duty {
				if n > 0 {
					// Yes.. The light is on fire :) -> Turn it OFF
					if err = picow.SetDuty(device, ColorOFF.GetDuty(device.Type)...); err != nil {
						d.errChannel <- fmt.Errorf("Failed to turn OFF \"%s\": %v", deviceHost, err)
						return
					}
					return
				}
			}

			// Light is sleeping -> Wake it up (For now, just set it to white color)
			if err = picow.SetDuty(device, ColorWhite.GetDuty(device.Type)...); err != nil {
				d.errChannel <- fmt.Errorf("Failed to set duty (%v) for \"%s\": %v", ColorWhite.GetDuty(device.Type), deviceHost, err)
				return
			}
		} else {
			d.errChannel <- fmt.Errorf("Failed to retrieve duty from \"%s\" (%s): %s", deviceHost, device.Addr, err)
			return
		}

		return
	}()
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
