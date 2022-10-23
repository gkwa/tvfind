// https://docs.dagger.io/1205/container-images#automation

package main

import (
	"dagger.io/dagger"
	"universe.dagger.io/docker"
	"universe.dagger.io/docker/cli"
)

dagger.#Plan & {
	client: {
		network: "unix:///var/run/docker.sock": connect: dagger.#Socket
	}

	actions: versions: {
		"8.0": _
		"5.7": _

		// This is a template
		// See https://cuelang.org/docs/tutorials/tour/types/templates/
		[tag_iter=string]: {
			build: docker.#Build & {
				steps: [
					docker.#Pull & {
						source: "mysql:\(tag_iter)"
					},
					docker.#Set & {
						config: cmd: [
							"--character-set-server=utf8mb4",
							"--collation-server=utf8mb4_unicode_ci",
						]
					},
				]
			}

			load: cli.#Load & {
				image: build.output
				host:  client.network."unix:///var/run/docker.sock".connect
				tag:   "mysql:\(tag_iter)"
			}

			image: build.output
		}
	}
}
