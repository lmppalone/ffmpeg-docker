package main

import (
	"context"
	"log"
	"net/http"
	"os/exec"
	"time"
)

func main() {
	r := http.NewServeMux()

	r.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		// context
		ctx, cancel := context.WithTimeout(r.Context(), time.Second*7)
		defer cancel()

		// command
		cmd := exec.CommandContext(ctx, "ffmpeg", "-version")

		// write output to response writer
		cmd.Stdout = w

		// run command
		err := cmd.Run()
		if err != nil {
			log.Println(err)
			w.WriteHeader(http.StatusInternalServerError)
			w.Write([]byte("something went wrong :("))
			return
		}
	})

	log.Println("starting server on port 3001")
	log.Fatalln(http.ListenAndServe(":3001", r))
}
