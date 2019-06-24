remote_user = root
remote_host = 167.71.175.221
remote_dir = /var/webcat

build-image:
	docker build -f Dockerfile.build -t elixir-ubuntu:latest .	
build:
	docker run -v $$(pwd):/opt/build --rm -it elixir-ubuntu:latest /opt/build/bin/build
deploy:
	ssh $(remote_user)@$(remote_host) mkdir -p $(remote_dir)
	scp rel/artifacts/webcat-*.tar.gz $(remote_user)@$(remote_host):$(remote_dir)/server.tar.gz
	ssh $(remote_user)@$(remote_host) tar -xvzf $(remote_dir)/server.tar.gz -C $(remote_dir)
	ssh $(remote_user)@$(remote_host)	'test $$(ps -A | grep beam | wc -c) != 0 && $(remote_dir)/bin/webcat stop'
	ssh $(remote_user)@$(remote_host) $(remote_dir)/bin/webcat start
