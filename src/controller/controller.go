package controller

import (
	"fmt"
	"openlinkhub_tray/src/common"
	"openlinkhub_tray/src/systray"
	"sync"
	"time"
)

var (
	menuMutex sync.Mutex
	queueTime = 60
)

// processMenu will process any menu adding / changes
func processMenu() {
	menuMutex.Lock()
	defer menuMutex.Unlock()
	response, err := common.LoadDataFromBackend()
	if err == nil {
		systray.SyncBatteryToMenu(response)
	} else {
		fmt.Println("Failed to load data from backend. Error:", err)
	}
}

func Init() {
	ready := make(chan struct{})
	go func() {
		systray.Init(ready)
	}()

	<-ready // Wait for systray to be ready

	go func() {
		ticker := time.NewTicker(time.Duration(queueTime) * time.Second)
		defer ticker.Stop()

		processMenu()
		for range ticker.C {
			processMenu()
		}
	}()
	select {}
}
