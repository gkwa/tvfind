package main

import (
    "dagger.io/dagger"
    "universe.dagger.io/docker"
)

// This action builds a docker image from a python app.
// Build steps are defined in an inline Dockerfile.
#PythonBuild: docker.#Dockerfile & {
    dockerfile: contents: """
        FROM python:latest
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
    client: filesystem: "./": read: contents: dagger.#FS

    actions: build: #PythonBuild & {
        source: client.filesystem."./".read.contents
    }
}
