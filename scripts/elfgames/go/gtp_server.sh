#!/bin/bash

pushd .
    cd ../..
    source ./devmode_set_pythonpath.sh
popd

socat EXEC:"./gtp.sh pretrained-go-19x19-v2.bin --verbose --gpu 0 --num_block 20 --dim 256 --mcts_puct 1.50 --batchsize 16 --mcts_rollout_per_batch 16 --mcts_threads 2 --mcts_rollout_per_thread 8192 --resign_thres 0.05 --mcts_virtual_loss 1" TCP-LISTEN:8487,fork,reuseaddr
