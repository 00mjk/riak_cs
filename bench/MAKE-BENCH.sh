#!/bin/sh

# NOTE: The current working dir must be basho_bench's top level source dir

if [ -z "$RIAK_CS_SRC_DIR" ]; then
    RIAK_CS_SRC_DIR=/tmp/delme.cs2
fi

rm -rf $RIAK_CS_SRC_DIR
mkdir -p $RIAK_CS_SRC_DIR

(
    cd $RIAK_CS_SRC_DIR
    git clone git@github.com:basho/riak_cs.git
    mv riak_cs/* .
    mv riak_cs/.??* .
    rmdir riak_cs
    git checkout master
    perl -ni -e 'if (/riak_test.*github.com/) { print "%% ", $_ } else { print $_ }' rebar.config
    make clean
    make
)

git checkout master
make clean
perl -ni -e 'if (/escript_emu_args/) { print "%% ", $_ } else { print $_ }' rebar.config
echo '{escript_emu_args, "%%! +K true                                                                    \n"}.' >> rebar.config
make

erlc -o deps.riak-cs/ebin $RIAK_CS_SRC_DIR/bench/basho_bench_driver_moss.erl
erlc -o deps.riak-cs/ebin -I $RIAK_CS_SRC_DIR/deps/stanchion/include $RIAK_CS_SRC_DIR/deps/stanchion/src/stanchion_auth.erl

cp $RIAK_CS_SRC_DIR/bench/moss.config.sample examples/riak-cs.config


