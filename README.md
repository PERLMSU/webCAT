# webCAT
## Requirements
* Python 3.6, [Pipenv](https://github.com/pypa/pipenv#installation), and [Pyenv](https://github.com/pyenv/pyenv#installation)
* Node 10+, [NVM](https://github.com/creationix/nvm#installation) and [Yarn](https://yarnpkg.com/en/docs/install)

If you're on MacOS, you can get all of the requirements with the following commands:
```bash
# NVM and Node.js
$ curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
$ nvm install 10

# Yarn
$ brew install yarn --without-node

# Pyenv and Pipenv
$ brew install pipenv pyenv

# Python 3.6
$ pyenv install 3.6.5
```
## Getting Running
1. Install dependencies via `pipenv install`
2. Get a shell with the virtualenv activated via `pipenv shell` 