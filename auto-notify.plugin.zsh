export AUTO_NOTIFY_VERSION="0.1.0"

# Command that the user has executed
AUTO_COMMAND=""
# Full command that the user has executed after alias expansion
AUTO_COMMAND_FULL=""
# Command start time in seconds since epoch
AUTO_COMMAND_START=0
# Threshold for when to automatically show a notification
AUTO_NOTIFY_THRESHOLD=5
# List of commands/programs to ignore sending notifications for
AUTO_NOTIFY_IGNORE=("vim" "nvim" "emacs" "less" "more" "man")

autoload -Uz add-zsh-hook


function _auto_notify_message() {
    local command="$1"
    local elapsed="$2"
    # Run using echo -e in order to make sure notify-send picks up new line
    echo -e "\"$command\" has completed\n(Total time: $elapsed seconds)"
}

function _is_auto_notify_ignored() {
    local command="$1"
    for ignore in $AUTO_NOTIFY_IGNORE; do
        if [[ "$command" == "$ignore"* ]]; then
            print "yes"
            return
        fi
    done
    print "no"
}

function _auto_notify_send() {
    local current="$(date +"%s")"

    if [[ "$(_is_auto_notify_ignored "$AUTO_COMMAND_FULL")" == "yes" ]]; then
        return
    fi

    let "elapsed = current - AUTO_COMMAND_START"

    if [[ -n "$AUTO_COMMAND" && $elapsed -gt $AUTO_NOTIFY_THRESHOLD ]]; then
        notify-send "$(_auto_notify_message "$AUTO_COMMAND" "$elapsed")"
    fi
}

function _auto_notify_track() {
    AUTO_COMMAND="$1"
    AUTO_COMMAND_FULL="$3"
    AUTO_COMMAND_START="$(date +"%s")"
}

function disable_auto_notify() {
    add-zsh-hook -D preexec _auto_notify_track
    add-zsh-hook -D precmd _auto_notify_send
}

function enable_auto_notify() {
    add-zsh-hook preexec _auto_notify_track
    add-zsh-hook precmd _auto_notify_send
}

autoload -Uz add-zsh-hook
enable_auto_notify
