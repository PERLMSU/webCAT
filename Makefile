app_name = $(shell grep 'app:' mix.exs | sed -e 's/\[//g' -e 's/ //g' -e 's/app://' -e 's/[:,]//g')
version = $(shell grep 'version:' mix.exs | cut -d '"' -f2)
artifact = rel/artifacts/$(app_name)-$(version).tar.gz
remote_user = root
remote_host = 67.207.84.116
remote_dir = /var/$(app_name)

build-image:
	docker build -f Dockerfile.build -t elixir-ubuntu:latest .
build:
	docker run -v $$(pwd):/opt/build --rm -it elixir-ubuntu:latest /opt/build/bin/build
fetch_deps:
	mix deps.get
	(cd frontend && yarn)
clean:
	@echo "This will remove all of the files in _build and node_modules"
	sudo rm -f $(artifact)
	sudo rm -rf _build .mix frontend/node_modules
deploy:
	ssh $(remote_user)@$(remote_host) mkdir -p $(remote_dir)
	scp $(artifact) "$(remote_user)@$(remote_host):$(remote_dir)/server.tar.gz"
	ssh $(remote_user)@$(remote_host)	"pgrep beam >/dev/null && $(remote_dir)/bin/$(app_name) stop"
	ssh $(remote_user)@$(remote_host) tar -xzf $(remote_dir)/server.tar.gz --overwrite -C $(remote_dir)
	ssh $(remote_user)@$(remote_host) $(remote_dir)/bin/$(app_name) start
