export AUTO_NOTIFY_VERSION="0.1.0"

AUTO_COMMAND=""
AUTO_COMMAND_START=0
AUTO_NOTIFY_THRESHOLD=5
AUTO_NOTIFY_IGNORE=("vim" "nvim" "emacs" "less" "more" "man")

autoload -Uz add-zsh-hook


function _auto_notify_message() {
    local command="$1"
    local elapsed="$2"
    # Run using echo -e in order to make sure notify-send picks up new line
    echo -e "'$command' has completed\n(Total time: $elapsed seconds)"
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

    if [[ "$(_is_auto_notify_ignored "$AUTO_COMMAND")" == "yes" ]]; then
        return
    fi

    let "elapsed = current - AUTO_COMMAND_START"

    if [[ -n "$AUTO_COMMAND" && $elapsed -gt $AUTO_NOTIFY_THRESHOLD ]]; then
        notify-send "$(_auto_notify_message "$AUTO_COMMAND" "$elapsed")"
    fi
}

function _auto_notify_track() {
    AUTO_COMMAND="$1"
    AUTO_COMMAND_START="$(date +"%s")"
}

autoload -U add-zsh-hook
add-zsh-hook preexec _auto_notify_track
add-zsh-hook precmd _auto_notify_send
