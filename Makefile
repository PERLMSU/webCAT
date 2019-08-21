remote_user = root
remote_host = 167.71.175.221
remote_dir = /var/webcat

build-image:
	docker build -f Dockerfile.build -t elixir-ubuntu:latest .	
build:
	docker run -v $$(pwd):/opt/build --rm -it elixir-ubuntu:latest /opt/build/bin/build
clean:
	echo "rm -f rel/artifacts/webcat-*.tar.gz" | zsh
	rm -rf _build/prod .mix
deploy:
	ssh $(remote_user)@$(remote_host) mkdir -p $(remote_dir)
	echo "ssh $(remote_user)@$(remote_host) \"cat > $(remote_dir)/server.tar.gz\" < rel/artifacts/webcat-*.tar.gz" | zsh
	ssh $(remote_user)@$(remote_host) tar -xvzf $(remote_dir)/server.tar.gz -C $(remote_dir)
	ssh $(remote_user)@$(remote_host)	'test $$(ps -A | grep beam | wc -c) != 0 && $(remote_dir)/bin/webcat stop'
	ssh $(remote_user)@$(remote_host) $(remote_dir)/bin/webcat start
