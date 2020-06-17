{ pkgs ? import (fetchTarball { url = "channel:nixos-20.03"; }) { }, ghc ? pkgs.ghc }:
with pkgs;
with lib;
haskell.lib.buildStackProject rec {
  inherit ghc;
  name = "webcatEnv";  
  buildInputs = [ stdenv procps gnugrep zlib postgresql_12 postgresql_12.lib flyway socat ]
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
  YESOD_PGUSER = "webcat";
  YESOD_PGPASS = "";
  YESOD_PGHOST = SOCKET_DIR;

  FLYWAY_PORT = toString 5433;
  

  shellHook =
    let
      migrateCommand = "flyway migrate -user=${YESOD_PGUSER} -url='jdbc:postgresql://localhost:${FLYWAY_PORT}/webcat?user=webcat' -password='${YESOD_PGPASS}' -locations=filesystem:${./sql},";
      baselineCommand = "flyway baseline -user=${YESOD_PGUSER} -url='jdbc:postgresql://localhost:${FLYWAY_PORT}/webcat?user=webcat' -password='${YESOD_PGPASS}'";
    in ''
    # Make sure directories exist
    mkdir -p ${SOCKET_DIR}

    # Forward traffic from TCP to socket for Flyway
    socat -d -d TCP4-LISTEN:${FLYWAY_PORT},fork UNIX-CONNECT:${SOCKET_DIR}/.s.PGSQL.5432 &

    # Add scripts to path
    export PATH="${SHELL_DIR}/bin/:$PATH"
    
    # If postgres socket dir doesn't exist, create it.
    if [ ! -d ${SOCKET_DIR} ]; then
      mkdir -p ${SOCKET_DIR}
    fi

    if [ ! -d ${PGDATA} ]; then
        pg_init;
        # Migrate
        ${baselineCommand};
        ${migrateCommand};
        kill $1;
        # Exit trap to stop services
        trap "pg_stop" EXIT
    else
        # Warning for non-local running PostgreSQL instance.
        if [ `ps aux | grep postgres | wc -l` -ne 1 ] && [ ! -f "${PGDATA}/postmaster.pid" ]; then
            printf "\n\e[31mA non-local PostgreSQL instance is already running. Be sure this is the one you want to use. If you're using Lorri, ignore this message.\e[0m\n\n"
        elif [ ! -f "${PGDATA}/postmaster.pid" ]; then
            pg_start;

            # Migrate
            ${migrateCommand};
            kill $!;
            # Exit trap to stop services
            trap "pg_stop" EXIT
        fi
    fi
  '';
}
