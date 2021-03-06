#!/bin/sh
#
# z3bra - 2014 (c) wtfpl
# window focus wrapper that sets borders and can focus next/previous window

BW=${BW:-2}                    # border width
ACTIVE=${ACTIVE:-0xa7a7a7}     # active border color
INACTIVE=${INACTIVE:-0x4e4e4e} # inactive border color

# get current window id
CUR=$(pfw)

usage() {
    echo "usage: $(basename $0) <next|prev|wid>"
    exit 1
}

setborder() {
    ROOT=$(lsw -r)

    # check if window exists
    wattr $2 || return

    # do not modify border of fullscreen windows
    if [ -f $HOME/.fwin ]; then
        wid=$(cat $HOME/.fwin | awk '{print $5}')
        if [ $wid = $2 ]; then
            return
        fi
    fi

    case $1 in
        active)   chwb -s $BW -c $ACTIVE $2 ;;
        inactive) chwb -s $BW -c $INACTIVE $2 ;;
    esac
}

case $1 in
    next) wid=$(lsw|grep -v $CUR|sed '1 p;d') ;;
    prev) wid=$(lsw|grep -v $CUR|sed '$ p;d') ;;
    0x*) wattr $1 && wid=$1 ;;
    *) usage ;;
esac

# exit if we can't find another window to focus
test -z "$wid" && echo "$(basename $0): can't find a window to focus" >&2 && exit 1

setborder inactive $CUR # set inactive border on current window
setborder active $wid   # activate the new window
chwso -r $wid           # put it on top of the stack
wtf $wid                # set focus on it

# you might want to remove this for sloppy focus
wmp -a $(wattr xy $wid) # move the mouse cursor to
wmp -r $(wattr wh $wid) # .. its bottom right corner
