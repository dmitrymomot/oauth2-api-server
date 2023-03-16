package useragent

import (
	"net/http"

	"github.com/gamebtc/devicedetector"
	"github.com/pkg/errors"
)

// UserAgent is a struct that contains user agent information
type UserAgent struct {
	UserAgent     string `json:"user_agent"`
	IpAddress     string `json:"ip_address"`
	DeviceType    string `json:"device_type"`
	DeviceModel   string `json:"device_model"`
	DeviceBrand   string `json:"device_brand"`
	ClientType    string `json:"client_type"`
	ClientName    string `json:"client_name"`
	ClientVersion string `json:"client_version"`
	Os            string `json:"os"`
	OsVersion     string `json:"os_version"`
}

// Parse parses user agent information from http.Request
// and returns UserAgent struct
func Parse(r *http.Request) (UserAgent, error) {
	uaStr := r.UserAgent()

	dd, err := devicedetector.NewDeviceDetector("lib/useragent/regexes")
	if err != nil {
		return UserAgent{}, errors.Wrap(err, "failed to init device detector")
	}

	info := dd.Parse(uaStr)

	return UserAgent{
		UserAgent:     uaStr,
		IpAddress:     r.RemoteAddr,
		DeviceType:    info.GetDevice().Type,
		DeviceModel:   info.GetDevice().Model,
		DeviceBrand:   info.GetDevice().Brand,
		ClientType:    info.GetClient().Type,
		ClientName:    info.GetClient().Name,
		ClientVersion: info.GetClient().Version,
		Os:            info.GetOs().Name,
		OsVersion:     info.GetOs().Version,
	}, nil
}
