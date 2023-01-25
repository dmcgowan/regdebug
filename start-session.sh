#!/bin/sh

tmux new-session -s regdebug -n root -d -c /root "bash -l"
tmux split-window -h -t regdebug "mitmproxy -k -p 8888"

tmux select-layout -t regdebug tiled
tmux select-pane -t 0

tmux attach-session -t regdebug
