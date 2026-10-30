package main

import (
	"log"
	"runtime"

	"github.com/nanu-c/qml-go"
)

var (
	devices *Devices = NewDevices(
		Device{Host: "192.168.178.50", Port: 3000, Name: "📺 Wohnzimmer"},
		Device{Host: "192.168.178.68", Port: 3000, Name: "💻 Schreibtisch"},
		Device{Host: "192.168.178.62", Port: 3000, Name: "🚽 Badezimmer"},
		Device{Host: "192.168.178.67", Port: 3000, Name: "🛌 Schlafzimmer"},
		Device{Host: "192.168.178.54", Port: 3000, Name: "✂️ Arbeitszimmer"},
	)
)

func init() {
	runtime.LockOSThread() // NOTE: Potential quick-fix for getting stuck during app startup 
}

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

type Device struct {
	Host string
	Port int
	Name string
}

type Devices struct {
	list []Device
}

func NewDevices(d ...Device) *Devices {
	return &Devices{
		list: d,
	}
}

func (d *Devices) List() []Device {
	return d.list
}
