$(luarocks path)
scriptdir=$(readlink -f $0 | xargs dirname)
export PATH="${PATH}:${scriptdir}"
export LUA_PATH="${LUA_PATH};${scriptdir}/?.lua"
