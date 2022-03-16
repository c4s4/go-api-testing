package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

type Response struct {
	Message string `json:"message"`
}

func TestHello(t *testing.T) {
	engine := gin.Default()
	engine.GET("/hello/:name", Hello)
	recorder := httptest.NewRecorder()
	request, err := http.NewRequest("GET", "/hello/World", nil)
	if err != nil {
		t.Fatalf("building request: %v", err)
	}
	engine.ServeHTTP(recorder, request)
	if recorder.Code != 200 {
		t.Fatalf("bad status code: %d", recorder.Code)
	}
	var response Response
	body := recorder.Body.String()
	if err != nil {
		t.Fatalf("reading response body: %v", err)
	}
	if err := json.Unmarshal([]byte(body), &response); err != nil {
		t.Fatalf("parsing json response: %v", err)
	}
	if response.Message != "Hello World!" {
		t.Fatalf("bad response message: %s", response.Message)
	}
}

func TestHelloNotFound(t *testing.T) {
	engine := gin.Default()
	engine.GET("/hello/:name", Hello)
	recorder := httptest.NewRecorder()
	request, err := http.NewRequest("GET", "/hello", nil)
	if err != nil {
		t.Fatalf("building request: %v", err)
	}
	engine.ServeHTTP(recorder, request)
	if recorder.Code != 404 {
		t.Fatalf("bad status code: %d", recorder.Code)
	}
}
