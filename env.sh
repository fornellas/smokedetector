PREFIX="$(realpath "$(dirname "$0")")"
export GEM_HOME="$PREFIX/.gem_home"
PATH="/opt/ruby21/bin:$PREDIX/bin:$GEM_HOME/bin:$PATH"
