package main

import (
	"log"
	"strconv"

	"github.com/nanu-c/qml-go"
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

	testvar := TestStruct{Message: "Hello World", Number: 1}

	context := engine.Context()
	context.SetVar("testvar", &testvar)

	testvar.GetMessage()

	win := component.CreateWindow(context)
	testvar.Root = win.Root()
	
	win.Show()
	win.Wait()

	return nil
}

type TestStruct struct {
	Root    qml.Object
	Message string
	Output  string
	Number  int
}

func (testvar *TestStruct) GetMessage() {
	//go func() {
		testvar.Number = testvar.Number + 1
		testvar.Output = "Counter " + strconv.Itoa(testvar.Number)
		qml.Changed(testvar, &testvar.Output)
	//}()
}
