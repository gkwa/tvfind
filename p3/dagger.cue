// https://docs.dagger.io/1221/action/

package main

import (
	"dagger.io/dagger"
	"dagger.io/dagger/core"
)

dagger.#Plan & {
	// Say hello by writing to a file
	actions: {
		hello: #AddHello & {
			dir: client.filesystem.".".read.contents
		}
	}
	client: {
		network: "unix:///var/run/docker.sock": connect: dagger.#Socket
		filesystem: ".": {
			read: contents:  dagger.#FS
			write: contents: actions.hello.result
		}
	}

}

// Write a greeting to a file, and add it to a directory
#AddHello: {
	// The input directory
	dir: dagger.#FS

	// The name of the person to greet
	name: string | *"world"

	write: core.#WriteFile & {
		input:    dir
		path:     "hello-\(name).txt"
		contents: "hello, \(name)!"
	}

	// The directory with greeting message added
	result: write.output
}
