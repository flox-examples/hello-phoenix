{
  pkgs,
  stdenv,
  lib,
  inputs,
}:
with inputs.floxpkgs.inputs.nixpkgs.evalCatalog.${pkgs.system};
  lib.mkEnv {
    packages = [stable.postgresql_14.latest stable.elixir_1_14 stable.entr stable.hivemind stable.jq stable.inotify-tools];
    env = {};
    postShellHook = ''
      # Generic shell variables

      # Postgres environment variables
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
        echo "listen_addresses='*'" >> postgres_data/postgresql.conf
        echo "unix_socket_directories='$PWD/postgres'" >> postgres_data/postgresql.conf
        echo "unix_socket_permissions=0700" >> $PWD/postgres_data/postgresql.conf
      fi

      # As an example, you can run any CLI commands to customize your development shell
      #psql -p 5435 postgres -c 'create extension if not exists postgis' || true

      # This creates mix variables and data folders within your project, so as not to pollute your system
      mkdir -p .nix-mix
      mkdir -p .nix-hex
      export MIX_HOME=$PWD/.nix-mix
      export HEX_HOME=$PWD/.nix-hex
      export PATH=$MIX_HOME/bin:$PATH
      export PATH=$HEX_HOME/bin:$PATH
      echo 'To run the services configured here, you can run the `hivemind` command'
    '';
  }
