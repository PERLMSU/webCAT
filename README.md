# WebCAT
## Requirements
  * Elixir 1.8
  * Node.js 11
  * Docker and docker-compose
  * Yarn
  * GNU Make

## Development
  * Install dependencies with `mix deps.get`
  * Start database with `docker-compose up -d`
  * Create and migrate your database with `mix do ecto.setup, ecto.seed.integration`
  * Start application with `mix phoenix.server`

Now you can visit [`localhost:8080`](http://localhost:8080) from your browser.

## Building and deployment
  * Build the build image with `make build-image`
  * Build the application release with `make build` 
  * Deploy to the server with `make deploy`
  
You'll need to have your SSH keys all set up for the automated deployment to work.
