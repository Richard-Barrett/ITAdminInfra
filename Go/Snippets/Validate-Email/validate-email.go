package main

import (
	"fmt"
	"regexp"
)

var emailRegex = regexp.MustCompile("^[a-zA-Z0-9.!#$%&'*+\\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$")

func main() {
	// Valid example
	e := "test@golangcode.com"
	if isEmailValid(e) {
		fmt.Println(e + " is a valid email")
	}

	// Invalid example
	if !isEmailValid("just text") {
		fmt.Println("not a valid email")
	}
}

// isEmailValid checks if the email provided passes the required structure and length.
func isEmailValid(e string) bool {
	if len(e) < 3 && len(e) > 254 {
		return false
	}
	return emailRegex.MatchString(e)
}
