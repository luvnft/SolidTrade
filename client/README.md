# Getting Started

## Prerequisites

1. [Task](https://taskfile.dev/)

## Installation

1. run `task reset` to remove builds and install dependencies
1. run `task gen` to generate few files (i10n and json mapping)
1. run `task api:server` or `task api:no_build_server` to not rebuild the api.
   This will start the required services for the api to run
1. go to `http://localhost:4551` and copy the url
1. create a `config.yml` in the `assets/config` folder and paste the url for the
   base url
1. finally run `task dev` to start the development or start debugging in vs code
