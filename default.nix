with import <nixpkgs> {};
stdenv.mkDerivation rec {
  name = "env";
  env = buildEnv { name = name; paths = buildInputs; };
  LANG = "en_US.UTF-8";
  PGDATA="/home/mog/code/elixir/test/post";
  buildInputs = [
    git
    elixir
    nodejs
    postgresql
    stdenv
    zlib
    glibcLocales
    inotify-tools
    screen
    ncurses
  ];
  pathsToLink = [ "/include" ];

  shellHook = ''
    function phoenix {
      iex -S mix phoenix.server
    }
  '';
}
