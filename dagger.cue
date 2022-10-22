package main

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
	"universe.dagger.io/docker/cli"
)

// This action builds a docker image from a python app.
// Build steps are defined in an inline Dockerfile.
#PythonBuild: docker.#Dockerfile & {
	dockerfile: contents: """
		FROM python:3.10.8-slim
		RUN apt-get update -y
		RUN apt-get install -y python3-pip python-dev build-essential
		COPY . /app
		WORKDIR /app
		RUN pip install flask
		ENTRYPOINT ["python"]
		CMD ["main.py"]
		"""
}

// Example usage in a plan
dagger.#Plan & {
	client: {
		filesystem: "./": read: contents: dagger.#FS
		network: "unix:///var/run/docker.sock": connect: dagger.#Socket
	}

	actions: {
		build: #PythonBuild & {
			source: client.filesystem."./".read.contents
		}
		load: cli.#Load & {
			image: build.output
			host:  client.network."unix:///var/run/docker.sock".connect
			tag:   "myimage"
		}
	}
}
