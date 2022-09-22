#!/usr/bin/env bash

i3m () {
    i3-msg "$@" 2>&1 >/dev/null
}

next-output () {
    local ws=$(i3-msg -t get_workspaces | jq -r '.[] | select(.visible) | [.output, .focused] | @tsv')
    echo "$ws
$ws" | grep -A 1 true | grep -v true | head -n 1 | cut -f 1 -d $'\t'    
}

warp () {
    xdotool getactivewindow mousemove --polar --window %1 0 0
}

case $1 in
    swap)
        # todo preserve focus
        declare -A next_output
        last_output=""
        first_output=""
        for output in $(i3-msg -t get_outputs | jq -r '.[] | select(.active) | .name'); do
            first_output=${first_output:-$output}
            next_output[$output]=$last_output
            last_output=$output
        done
        next_output[$first_output]=$last_output
        i3-msg -t get_workspaces | jq -r '.[] | [.visible, .output, .name] | @sh' |
            {
                com="nop"
                endcom="nop"
                while read -r visible output name; do
                    eval "name=$name"
                    eval "output=$output"
                    com="${com}, workspace \"$name\", move workspace to output \"${next_output[$output]}\""
                    if [[ $visible = true ]]; then
                        endcom="$endcom, workspace \"$name\""
                    fi
                done
                i3m $com
                i3m $endcom
            }
        ;;
    focus-next)
        ws=$(next-output)
        i3m "focus output \"$ws\""
        warp
        ;;
    shift-next)
        ws=$(next-output)
        i3m "move container to output \"$ws\"; focus output \"$ws\""
        warp
        ;;
    pack)
        L=1
        i3-msg -t get_workspaces | jq -r 'sort_by(.num) |.[]| [.num, .name]|@sh' |
            {
                C="nop"
                while read -r num nam; do
                    if [[ $num = 10 ]]; then
                        continue
                    fi
                    nam=$(eval "echo $nam")
                    if [[ $num -ne $L ]]; then
                        C="$C; rename workspace \"$nam\" to \"${nam/$num/$L}\""
                    fi
                    L=$((L+1))
                done
                echo $C
                i3-msg "$C"
            }
        ;;
    scratchpad)
        cur=$(i3-msg -t get_tree | jq -r '.. | select(type == "object" and .scratchpad_state != "none") | .. | select(type == "object" and .nodes == [] and .focused) | .id')
        
        if [[ -n $cur ]]; then
            i3m "move scratchpad, scratchpad show"
        else
            next=$(i3-msg -t get_tree | jq '[..|select(type=="object" and .output =="__i3" and .type=="con" and .window)]|.[length-1]|.window')
            i3m "[id=$next] scratchpad show"
        fi
        ;;
esac
