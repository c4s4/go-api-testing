//go:build integration
// +build integration

package main

import (
	"net"
	"os/exec"
	"testing"
	"time"
)

func WaitServer() {
	timeout := 10 * time.Millisecond
	for {
		conn, err := net.DialTimeout("tcp", "127.0.0.1:8080", timeout)
		if err == nil {
			conn.Close()
			return
		}
		time.Sleep(timeout)
	}
}

func TestIntegration(t *testing.T) {
	go Engine().Run()
	WaitServer()
	out, err := exec.Command("venom", "run", "test.yml").Output()
	if err != nil {
		t.Fatalf("running venom: %s", string(out))
	}
}
