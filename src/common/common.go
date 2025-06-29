package common

import (
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"strconv"
	"time"
)

var BackendAddr string

type Response struct {
	Code   int  `json:"code"`
	Status int  `json:"status"`
	Data   Data `json:"data"`
}

type Data struct {
	CpuTemp string                    `json:"cpu_temp"`
	GpuTemp string                    `json:"gpu_temp"`
	Battery map[string]BatteryDetails `json:"battery"`
}

type BatteryDetails struct {
	Device     string `json:"Device"`
	Level      int    `json:"Level"`
	DeviceType int    `json:"DeviceType"`
}

// LoadDataFromBackend will load systray data from backend service
func LoadDataFromBackend() (*Response, error) {
	url := fmt.Sprintf("http://%s/api/systray", BackendAddr)
	client := http.Client{Timeout: 5 * time.Second}

	resp, err := client.Get(url)
	if err != nil {
		return nil, err
	}
	defer func(Body io.ReadCloser) {
		err := Body.Close()
		if err != nil {

		}
	}(resp.Body)

	if resp.StatusCode != http.StatusOK {
		return nil, errors.New("Non-200 response code: " + strconv.Itoa(resp.StatusCode))
	}

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	var response Response
	err = json.Unmarshal(body, &response)
	if err != nil {
		return nil, err
	}
	return &response, nil
}
