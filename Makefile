init:
	# Install stack and yesod-devel if not found
	which stack || curl -sSL https://get.haskellstack.org/ | sh
build:
	stack build
hoogle:
	stack hoogle -- generate --local
	stack hoogle -- server --local --port=8080
run:
	stack evex -- yesod devel
test:
	stack test --fast --haddock-deps --flag webcat:library-only --flag webcat:dev
