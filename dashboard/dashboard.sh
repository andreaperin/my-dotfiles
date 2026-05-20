#!/usr/bin/env zsh

SESSION="dashboard"

# Kill old session
tmux kill-session -t $SESSION 2>/dev/null

# Create session
tmux new-session -d -s $SESSION

# Rename window
tmux rename-window "system"

tmux split-window -h -p 60

tmux select-pane -t 0

tmux split-window -v -p 10

tmux select-pane -t 2

tmux split-window -v -p 10
# Let tmux finish resizing
sleep 0.5

tmux select-pane -t 0
tmux send-keys "clear && fastfetch" C-m

tmux select-pane -t 3
tmux send-keys "clear && cava" C-m

tmux select-pane -t 2
tmux send-keys "clear && btop" C-m

tmux select-pane -t 1
tmux send-keys "clear && cbonsai -l -i" C-m

tmux select-pane -t 0

# Attach
tmux attach-session -t $SESSION
