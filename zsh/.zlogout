# Prevent /etc/zlogout's `clear` from destroying terminal scrollback.
#
# Many Linux distros (RHEL, Fedora, etc.) ship /etc/zlogout with `clear`
# for physical-console security. Over SSH + Zellij/tmux, this sends
# \e[3J which wipes the scrollback buffer in the multiplexer.
#
# ~/.zlogout is sourced BEFORE /etc/zlogout, so defining `clear` as a
# function here overrides the external command.

if [[ -n "$SSH_CONNECTION" ]]; then
  clear() { : }
fi
