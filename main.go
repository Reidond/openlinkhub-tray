package main

import (
	"flag"
	"fmt"
	"log"
	"net"
	"openlinkhub_tray/src/common"
	"openlinkhub_tray/src/controller"
)

func main() {
	ip := flag.String("ip", "127.0.0.1", "IP address of the OpenLinkHub service")
	port := flag.Int("port", 27003, "Port number of the OpenLinkHub service")
	flag.Parse()

	// Crash it
	if net.ParseIP(*ip) == nil {
		log.Fatalf("Invalid IP address: %s", *ip)
	}

	// Format backend address
	addr := fmt.Sprintf("%s:%d", *ip, *port)

	// Store it
	common.BackendAddr = addr

	// Run
	controller.Init()
}
