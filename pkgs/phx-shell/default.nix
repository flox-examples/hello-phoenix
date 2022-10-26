{pkgs, stdenv, lib, mkShell, ...}:

mkShell {
  name = "phoneix-shell";
  buildInputs = [pkgs.postgresql_14 pkgs.elixir pkgs.jq]
    ++ lib.optional stdenv.isLinux pkgs.inotify-tools
    ++ lib.optionals stdenv.isDarwin (with pkgs.darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);
  shellHook = ''
    export LOCALE_ARCHIVE=/usr/lib/locale/locale-archive
    export LC_ALL="en_US.UTF-8"
    export LC_CTYPE="en_US.UTF-8"
    export PGDATA=$PWD/postgres_data
    export PGHOST=$PWD/postgres
    export LOG_PATH=$PWD/postgres/LOG
    export PGDATABASE=postgres
    export DATABASE_URL="postgresql:///postgres?host=$PGHOST"
    if [ ! -d $PWD/postgres ]; then
      mkdir -p $PWD/postgres
    fi
    if [ ! -d $PGDATA ]; then
      echo 'Initializing postgresql database...'
      initdb $PGDATA --auth=trust >/dev/null
    fi
    #pg_ctl start -l $LOG_PATH -o "-p 5432 -c listen_addresses='*' -c unix_socket_directories=$PWD/postgres -c unix_socket_permissions=0700"
    #psql -p 5435 postgres -c 'create extension if not exists postgis' || true
    mkdir -p .nix-mix
    mkdir -p .nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-hex
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
  '';
}
