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

	DeviceStateError = "ERROR"
	DeviceStateON    = "ON"
	DeviceStateOFF   = "OFF"
)

var (
	devices *Devices = NewDevices(
		NewDevice("192.168.178.50", 3000, "Wohnzimmer", "📺", picow_models.DeviceTypeRGBW),
		NewDevice("192.168.178.68", 3000, "Schreibtisch", "💻", picow_models.DeviceTypeRGBW),
		NewDevice("192.168.178.62", 3000, "Badezimmer", "🚽", picow_models.DeviceTypeRGBW),
		NewDevice("192.168.178.67", 3000, "Schlafzimmer", "🛌", picow_models.DeviceTypeRGBW),
		NewDevice("192.168.178.54", 3000, "Arbeitszimmer", "✂️", picow_models.DeviceTypeRGBW),
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
	*picow_models.Device

	Icon string `json:"icon"`
	Name string `json:"name"` // Name of the device, **IMPORTANT:** Do not edit this, it will break things -> use the `SetName` method for this.
}

func NewDevice(host string, port int, name, icon string, device_type picow_models.DeviceType) *Device {
	return &Device{
		Device: picow_models.NewDevice(fmt.Sprintf("%s:%d", host, port), name, device_type),
		Icon:   icon,
		Name:   name,
	}
}

func (d *Device) SetName(name string) {
	d.Device.Name = name
	d.Name = name
}

// Devices QML handler for devices
//
// NOTE: Always use the `NewDevices` function for initializing this. It will make the error channel which is a private field.
type Devices struct {
	data []*Device

	errChannel         chan error
	_errChannelStop    chan error
	_errChannelRunning bool

	_root qml.Object
}

func NewDevices(d ...*Device) *Devices {
	return &Devices{
		data: d,
	}
}

func (d *Devices) List() string {
	return NewJSON(d.data)
}

func (d *Devices) StartErrorChannel(root qml.Object) {
	if root != nil {
		d._root = root
	}

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
			case err := <-d.errChannel:
				message := fmt.Sprintf("[ERROR] %v", err)
				fmt.Fprintln(os.Stderr, message)
				if d._root != nil {
					d._root.Call("log", message)
				}
			case <-d._errChannelStop:
				return
			}
		}
	}()
}

// PowerToggle does switch lights per device on an off
func (d *Devices) PowerToggle(addr string, powerToggleButton qml.Object) {
	d.StartErrorChannel(nil)

	go func() {
		device := d.get(addr)
		if device == nil {
			d.errChannel <- fmt.Errorf("Failed to retrieve device %s", addr)
			return
		}

		if duty, err := picow.GetDuty(device.Device); err == nil {
			for _, n := range duty {
				if n > 0 {
					// Yes.. The light is on fire :) -> Turn it OFF
					if err = picow.SetDuty(device.Device, ColorOFF.GetDuty(device.Type)...); err != nil {
						d.errChannel <- fmt.Errorf("Failed to turn OFF %s: %v", d.deviceString(device), err)
						powerToggleButton.Call("setState", DeviceStateError)
						return
					} else {
						powerToggleButton.Call("setState", DeviceStateOFF)
					}
					return
				}
			}

			// Light is sleeping -> Wake it up (For now, just set it to white color) -> Turn it ON
			if err = picow.SetDuty(device.Device, ColorWhite.GetDuty(device.Type)...); err != nil {
				d.errChannel <- fmt.Errorf("Failed to set duty (%v) %s: %v", ColorWhite.GetDuty(device.Type), d.deviceString(device), err)
				powerToggleButton.Call("setState", DeviceStateError)
				return
			} else {
				powerToggleButton.Call("setState", DeviceStateON)
			}
		} else {
			d.errChannel <- fmt.Errorf("Failed to retrieve duty from %s: %s", d.deviceString(device), device.Addr, err)
			return
		}

		return
	}()
}

// get ist private because i am not sure if `*picow_models.Device` return does work with QML (this `struct` ist set for QML)
func (d *Devices) get(addr string) *Device {
	for _, device := range d.data {
		if device.Addr == addr {
			return device
		}
	}
	return nil
}

func (d *Devices) deviceString(device *Device) string {
	if device.Device.Name != "" {
		return fmt.Sprintf("%s", device.Name)
	}
	return fmt.Sprintf("%s", device.Addr)
}
