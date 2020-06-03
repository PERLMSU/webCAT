{ pkgs ? import (fetchTarball { url = "channel:nixos-20.03"; }) { }, ghc ? pkgs.ghc }:
with pkgs;
with lib;
haskell.lib.buildStackProject rec {
  inherit ghc;
  name = "webcatEnv";  
  buildInputs = [ stdenv procps gnugrep zlib postgresql_12 ]
    ++ optionals stdenv.isDarwin (with darwin.apple_sdk.frameworks; [
      # For file_system on macOS.
      CoreFoundation
      CoreServices
    ]);

# These are nix variables AND environment vars in resulting shell
  SHELL_DIR = toString ./.nix-shell;
  PGDATA =  "${SHELL_DIR}/database";
  SOCKET_DIR =  "${SHELL_DIR}/sockets";


  # Yesod
  YESOD_PGPASS = "";
  YESOD_PGHOST = SOCKET_DIR;


  shellHook = ''
    # Add scripts to path
    export PATH="${SHELL_DIR}/bin/:$PATH"
    
    # If postgres socket dir doesn't exist, create it.
    if [ ! -d ${SOCKET_DIR} ]; then
      mkdir -p ${SOCKET_DIR}
    fi

    if [ ! -d ${PGDATA} ]; then
        pg_init;
        # Exit trap to stop services
        trap "pg_stop" EXIT

    else
        # Warning for non-local running PostgreSQL instance.
        if [ `ps aux | grep postgres | wc -l` -ne 1 ] && [ ! -f "${PGDATA}/postmaster.pid" ]; then
            printf "\n\e[31mA non-local PostgreSQL instance is already running. Be sure this is the one you want to use. If you're using Lorri, ignore this message.\e[0m\n\n"
        else
            pg_start;

            # Exit trap to stop services
            trap "pg_stop" EXIT
        fi
    fi

  '';
}
