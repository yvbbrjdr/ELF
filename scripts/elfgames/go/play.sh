#!/bin/bash

function next_player() {
    if [[ "$CURRENT" == "b" ]]; then
        CURRENT=w
        return
    fi
    CURRENT=b
}

pushd .
    cd ../..
    source ./devmode_set_pythonpath.sh
popd

PIPE="$(mktemp -u)"
mkfifo -m 600 "$PIPE"
while true; do
    sleep 1
done > "$PIPE" &

trap "rm -f \"$PIPE\" && kill 0" EXIT

./gtp.sh pretrained-go-19x19-v2.bin --verbose --gpu 0 --num_block 20 --dim 256 --mcts_puct 1.50 --batchsize 16 --mcts_rollout_per_batch 16 --mcts_threads 2 --mcts_rollout_per_thread 8192 --resign_thres 0.05 --mcts_virtual_loss 1 < "$PIPE" 2> /dev/null &

CURRENT=b

while true; do
    echo "showboard" > "$PIPE"
    read
    if [[ "$REPLY" == "g" ]]; then
        echo "genmove $CURRENT" > "$PIPE"
    elif [[ "$REPLY" == "s" ]]; then
        read
        echo "set_num_rollouts_per_thread $REPLY" > "$PIPE"
        continue
    elif [[ "$REPLY" == "u" ]]; then
        echo "undo" > "$PIPE"
    else
        echo "play $CURRENT $REPLY" > "$PIPE"
    fi
    next_player
done
