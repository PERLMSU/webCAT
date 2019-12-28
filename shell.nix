{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  inherit (lib) optional optionals;

  elixir = beam.packages.erlang.elixir;
  nodejs = nodejs-10_x;
  postgresql = postgresql_11;
in

mkShell {
  buildInputs = [ elixir nodejs yarn git postgresql killall ]
    ++ optional stdenv.isLinux inotify-tools # For file_system on Linux.
    ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      # For file_system on macOS.
      CoreFoundation
      CoreServices
    ]);

  PGDATA = toString ./db;
  PGHOST = toString ./postgres;
  NODE_MODULES = toString ./frontend/node_modules;

  shellHook = ''
    export PATH="$NODE_MODULES/.bin/:$PATH"

    if [ ! -d $PGHOST ]; then
      mkdir -p $PGHOST
    fi

    if [ ! -d $PGDATA ]; then
      echo 'Initializing postgresql database...'
      initdb $PGDATA --auth=trust >/dev/null
    fi

    (cd frontend && yarn --silent)

    # Warning for non-local running PostgreSQL instance.
    if [ `ps aux | grep postgres | wc -l` -ne 1 ] && [ ! -f "$PGDATA/postmaster.pid" ]; then
       printf "\n\e[31mA non-local PostgreSQL instance is already running. Be sure this is the one you want to use. If you're using Lorri, ignore this message.\e[0m\n\n"
    else
      pg_start
      trap "pg_stop" EXIT
    fi
  '';
}
