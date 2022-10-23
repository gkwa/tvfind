package main

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
	"universe.dagger.io/docker/cli"
)

// This action builds a docker image from a python app.
#PythonBuild: {
	// Source code of the Python application
	app: dagger.#FS

	_pull: docker.#Pull & {
		source: "python:3.9"
	}

	_copy: docker.#Copy & {
		input:    _pull.output
		contents: app
		dest:     "/app"
	}

	_run: docker.#Run & {
		input: _copy.output
		command: {
			name: "pip"
			args: ["install", "-r", "/app/requirements.txt"]
		}
	}

	_set: docker.#Set & {
		input: _run.output
		config: cmd: ["python", "/app/app.py"]
	}

	// Resulting container image
	image: _set.output
}

dagger.#Plan & {
	client: {
		filesystem: "./src": read: contents: dagger.#FS
		network: "unix:///var/run/docker.sock": connect: dagger.#Socket
	}

	actions: {
		load: cli.#Load & {
			image: build.image
			host:  client.network."unix:///var/run/docker.sock".connect
			tag:   "myimage"
		}

		build: #PythonBuild & {
			app: client.filesystem."./src".read.contents
		}

		push: docker.#Push & {
			image: build.image
			dest:  "localhost:5042/example"
		}
	}
}
