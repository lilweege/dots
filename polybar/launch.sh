killall -q polybar

#if type "xrandr"; then
#	for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
#		MONITOR=$m polybar --reload main &
#	done
#else
#	polybar --reload main &
#fi


# [ -n "`xrandr -q | grep 'DP-0 connected'`" ] && MONITOR=DP-0 TRAY_POS=right polybar --reload main &
# [ -n "`xrandr -q | grep 'DP-1-1 connected'`" ] && MONITOR=DP-1-1 polybar --reload second &

# while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

polybar --reload bar1 &
polybar --reload bar2 &
