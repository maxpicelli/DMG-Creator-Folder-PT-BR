#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
osascript -e "
tell application \"Terminal\"
    activate
    do script \"clear; \\\"$DIR/criar-dmg.sh\\\"; exit\"
end tell"
