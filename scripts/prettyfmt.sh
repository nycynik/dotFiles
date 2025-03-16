#!/bin/bash
# shellcheck disable=SC2034  # Unused variables used in other scripts
# ---------------------------------------------------------
#  Colors
# ---------------------------------------------------------
# Colors for printing
BLACK='\033[0;30m'
LIGHT_BLACK='\033[1;30m'
RED='\033[0;31m'
LIGHT_RED='\033[1;31m'
GREEN='\033[0;32m'
LIGHT_GREEN='\033[1;32m'
YELLOW='\033[0;33m'
LIGHT_YELLOW='\033[1;33m'
BLUE='\033[0;34m'
LIGHT_BLUE='\033[1;34m'
PURPLE='\033[0;35m'
LIGHT_PURPLE='\033[1;35m'
CYAN='\033[0;36m'
LIGHT_CYAN='\033[1;36m'
WHITE='\033[0;37m'
LIGHT_WHITE='\033[1;37m'
ORANGE='\033[0;91m'
LIGHT_ORANGE='\033[1;91m'
GRAY='\033[0;90m'
LIGHT_GRAY='\033[1;90m'

# Background colors
On_Red='\033[41m'         # Red
On_Cyan='\033[46m'        # Cyan
On_Blue='\033[44m'        # Blue
On_Black='\033[40m'       # Black
On_White='\033[47m'       # White
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Purple='\033[45m'      # Purple
On_Gray='\033[100m'       # Gray
# Text formatting
BOLD='\033[1m'
UNDERLINE='\033[4m'
ITALIC='\033[3m'
# Reset color
NC='\033[0m' # No Color

# ---------------------------------------------------------
#  Boxes
# ---------------------------------------------------------
# Box dimensions
BOX_WIDTH=60
HEIGHT=5
# Unicode box-drawing characters
BOX_LINE_TOP_LEFT="┌"
BOX_LINE_TOP_RIGHT="┐"
BOX_LINE_BOTTOM_LEFT="└"
BOX_LINE_BOTTOM_RIGHT="┘"
BOX_LINE_TOP_HORIZONTAL="─"
BOX_LINE_BOTTOM_HORIZONTAL="─"
BOX_LINE_VERTICAL_LEFT="│"
BOX_LINE_VERTICAL_RIGHT="│"
BOX_LINE_VERTICAL=" "
# Unicode block characters
BOX_FULL_VERTICAL="█"
BOX_FULL_BOTTOM_HORIZONTAL="▀"
BOX_FULL_TOP_HORIZONTAL="▄"
BOX_FULL_TOP_LEFT=" "
BOX_FULL_TOP_RIGHT=" "
BOX_FULL_BOTTOM_LEFT=" "
BOX_FULL_BOTTOM_RIGHT=" "
BOX_FULL_VERTICAL_LEFT=" "
BOX_FULL_VERTICAL_RIGHT=" "

# draw box line
# Usage: draw_box_line <Width> <BgColor> <left> <center> <right>
draw_box_line() {
    local width=$1
    local bg_color=$2
    local left_char=$3
    local center_char=$4
    local right_char=$5
    local draw_box=${6:-true}
    local box_width=$((width - 2))

    if [ "$draw_box" = true ]; then
        printf "${bg_color}%s%s%s${NC}\n" \
            "$left_char" \
            "$(repeat_char "$center_char" $((box_width-2)))" \
            "$right_char"
    else
        printf "${bg_color}%s${NC}\n" \
            "$(repeat_char "$center_char" $((box_width)))"
    fi
}

get_box_chars() {
    local box_type=${1:-"FULL"}

    if [ "$box_type" == "FULL" ]; then
        echo "$BOX_FULL_TOP_LEFT,$BOX_FULL_TOP_HORIZONTAL,$BOX_FULL_TOP_RIGHT,$BOX_FULL_VERTICAL,$BOX_FULL_VERTICAL_LEFT,$BOX_FULL_VERTICAL_RIGHT,$BOX_FULL_BOTTOM_LEFT,$BOX_FULL_BOTTOM_HORIZONTAL,$BOX_FULL_BOTTOM_RIGHT"
    elif [ "$box_type" == "LINE" ]; then
        echo "$BOX_LINE_TOP_LEFT,$BOX_LINE_TOP_HORIZONTAL,$BOX_LINE_TOP_RIGHT,$BOX_LINE_VERTICAL,$BOX_LINE_VERTICAL_LEFT,$BOX_LINE_VERTICAL_RIGHT,$BOX_LINE_BOTTOM_LEFT,$BOX_LINE_BOTTOM_HORIZONTAL,$BOX_LINE_BOTTOM_RIGHT"
    else
        echo " , , , , , , , , "
    fi
}

# Function to draw a box with either FULL or LINE characters
# Usage: draw_box <BoxType> <Title>
draw_box() {
    local box_type=${1:-"FULL"}
    local title=${2:-""}
    local draw_box=${3:-true}
    local bg_color=${4:-$On_Blue}
    local box_chars
    local width=$BOX_WIDTH
    local height=$HEIGHT
    local box_width=$((width - 2))

    # Set box characters based on box type
    IFS=',' read -r -a box_chars <<< "$(get_box_chars "$box_type")"

    # Draw the top of the box
    draw_box_line "$width" "$bg_color" "${box_chars[0]}" "${box_chars[1]}" "${box_chars[2]}" "$draw_box"

    # Draw the middle
    for ((i=1; i<height-1; i++)); do
        if [ $i -eq 2 ]; then
            printf "${bg_color}%s%s%s${NC}\n" "${box_chars[4]}" "$(center_text "$title" $((box_width - 2)))" "${box_chars[5]}"
        else
            draw_box_line "$width" "$bg_color" "${box_chars[4]}" " " "${box_chars[5]}" "$draw_box"
        fi
    done

    # Draw the bottom of the box
    draw_box_line "$width" "$bg_color" "${box_chars[6]}" "${box_chars[7]}" "${box_chars[8]}" "$draw_box"
}

# draw a single line, this is pretty much <HR>
# usage: draw_a_line <BoxType FULL|LINE> <BgColor>
draw_a_line() {
    local width=$BOX_WIDTH
    local box_type=${1:-'FULL'}
    local bg_color=${2:-${CYAN}}
    local box_chars

    IFS=',' read -r -a box_chars <<< "$(get_box_chars "$box_type")"

    draw_box_line "$width" "$bg_color" "${box_chars[6]}" "${box_chars[7]}" "${box_chars[8]}" "false"
}

# ---------------------------------------------------------
#  Draw Text
# ---------------------------------------------------------
# Draw a title
# Usage: draw_title <Title>
draw_title() {
    local title="$1"
    local bg_color=${2:-$On_Black}
    draw_box "LINE" "$title" "true" "$bg_color"
}

draw_sub_title() {
    local title="$1"
    local box_type=${2:-"FULL"}
    local bg_color=${3:-$On_Black}
    local box_chars
    local width=$BOX_WIDTH
    local box_width=$((width - 2))

    IFS=',' read -r -a box_chars <<< "$(get_box_chars "$box_type")"

    printf "$bg_color%s%s%s${NC}\n" "${box_chars[4]}" "$(center_text "$title" $((box_width - 2)))" "${box_chars[5]}"

}

# Function to repeat a character
# Usage: repeat_char <Character> <Count>
repeat_char() {
    printf "%0.s$1" $(seq 1 "$2")
}

# center text
# Usage: center_text <Text> <Width>
center_text() {
    local text="$1"
    local width="$2"
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%*s%s%*s" "$padding" "" "$text" "$((width - padding - ${#text}))" ""
}

# Colorful echo is a shortcut to drawing a colored line of text
# Usage: colorful_echo <Text>
function colorful_echo() {
  printf "%b${NC}\n" "$1"
}
