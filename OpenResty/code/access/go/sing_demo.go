package main

import (
	"crypto/md5"
	"encoding/hex"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"sort"
	"strings"
	"time"
)

func main() {
	params := map[string]string{
		"key":  "test",
		"name": "chaos",
		"age":  "27",
		"sex":  "man",
	}

	time := time.Now().UnixNano() / 1e6
	params["time"] = fmt.Sprintf("%d", time)

	fmt.Println(time)

	sign, err := getSignature(params, "123456")
	if err != nil {
		fmt.Println("Error generating signature:", err)
		return
	}

	fmt.Println(sign)

	params["sign"] = sign

	resp, err := doGet("http://127.0.0.1:8080/sign", params)
	if err != nil {
		fmt.Println("Error making GET request:", err)
		return
	}

	fmt.Println(resp)
}

func getSignature(params map[string]string, secret string) (string, error) {
	// Sort the params by key
	keys := make([]string, 0, len(params))
	for k := range params {
		keys = append(keys, k)
	}
	sort.Strings(keys)

	// Create the base string
	var basestring strings.Builder
	for i, k := range keys {
		if i > 0 {
			basestring.WriteString("&")
		}
		basestring.WriteString(k)
		basestring.WriteString("=")
		basestring.WriteString(params[k])
	}
	basestring.WriteString("&")
	basestring.WriteString(secret)

	fmt.Println("basestring=", basestring.String())

	// Create the MD5 hash
	hash := md5.New()
	hash.Write([]byte(basestring.String()))
	bytes := hash.Sum(nil)

	// Convert to hex string
	strSign := hex.EncodeToString(bytes)
	fmt.Println("strSign=", strSign)

	return strSign, nil
}

func doGet(urlStr string, params map[string]string) (string, error) {
	// Encode the query parameters
	values := url.Values{}
	for k, v := range params {
		values.Add(k, v)
	}
	urlStr = fmt.Sprintf("%s?%s", urlStr, values.Encode())

	// Make the GET request
	resp, err := http.Get(urlStr)
	if err != nil {
		return "", err
	}
	defer resp.Body.Close()

	// Read the response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return "", err
	}

	return string(body), nil
}
