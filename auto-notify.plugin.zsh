export AUTO_NOTIFY_VERSION="0.2.0"

# Threshold in seconds for when to automatically show a notification
export AUTO_NOTIFY_THRESHOLD=10
# List of commands/programs to ignore sending notifications for
export AUTO_NOTIFY_IGNORE=(
    "vim" "nvim" "less" "more" "man" "tig" "watch" "git commit" "top" "htop" "ssh" "nano"
)

function _auto_notify_message() {
    local command="$1"
    local elapsed="$2"
    local platform="$(uname)"
    # Run using echo -e in order to make sure notify-send picks up new line
    local text="$(echo -e "\"$command\" has completed\n(Total time: $elapsed seconds)")"

    if [[ "$platform" == "Linux" ]]; then
        notify-send "$text"
    elif [[ "$platform" == "Darwin" ]]; then
        # We need to escape quotes since we are passing a script into a command
        text="${text//\"/\\\"}"
        osascript -e "display notification \"$text\" with title \"Command Completed\""
    else
        printf "Unknown platform for sending notifications: $platform\n"
        printf "Please post an issue on gitub.com/MichaelAquilina/zsh-auto-notify/issues/\n"
    fi
}

function _is_auto_notify_ignored() {
    local command="$1"
    # split the command if its been piped one or more times
    local command_list=("${(@s/|/)command}")
    local target_command="${command_list[-1]}"
    # Remove leading whitespace
    target_command="$(echo "$target_command" | sed -e 's/^ *//')}"

    for ignore in $AUTO_NOTIFY_IGNORE; do
        if [[ "$target_command" == "$ignore"* ]]; then
            print "yes"
            return
        fi
    done
    print "no"
}

function _auto_notify_send() {
    if [[ -z "$AUTO_COMMAND" && -z "$AUTO_COMMAND_START" ]]; then
        return
    fi

    if [[ "$(_is_auto_notify_ignored "$AUTO_COMMAND_FULL")" == "no" ]]; then
        local current="$(date +"%s")"
        let "elapsed = current - AUTO_COMMAND_START"

        if [[ $elapsed -gt $AUTO_NOTIFY_THRESHOLD ]]; then
            _auto_notify_message "$AUTO_COMMAND" "$elapsed"
        fi
    fi

    # Empty tracking so that notifications are not
    # triggered for any commands not run (e.g ctrl+C when typing)
    _auto_notify_reset_tracking
}

function _auto_notify_track() {
    AUTO_COMMAND="$1"
    AUTO_COMMAND_FULL="$3"
    AUTO_COMMAND_START="$(date +"%s")"
}

function _auto_notify_reset_tracking() {
    # Command start time in seconds since epoch
    unset AUTO_COMMAND_START
    # Full command that the user has executed after alias expansion
    unset AUTO_COMMAND_FULL
    # Command that the user has executed
    unset AUTO_COMMAND
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

_auto_notify_reset_tracking
enable_auto_notify
