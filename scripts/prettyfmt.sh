
# Colors for printing (mostly skippable)
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
ITALIC='\033[3m'
# Reset color
NC='\033[0m' # No Color
On_Cyan='\033[46m'        # Cyan
On_Blue='\033[44m'        # Blue
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

# Function to repeat a character
repeat_char() {
    printf "%0.s$1" $(seq 1 $2)
}

# center text 
center_text() {
    local text="$1"
    local width="$2"
    local padding=$(( (width - ${#text}) / 2 ))
    printf "%*s%s%*s" "$padding" "" "$text" "$((width - padding - ${#text}))" ""
}

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
    local box_chars
    local width=$BOX_WIDTH
    local height=$HEIGHT
    local box_width=$((width - 2))
    local box_height=$((height - 2))
    local bg_color=$On_Blue

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

draw_title() {
    local title="$2"
    draw_box "LINE" "$title"
}

draw_sub_title() {
    local box_type=${1:-"FULL"}
    local title="$2"
    local box_chars
    local width=$BOX_WIDTH
    local box_width=$((width - 2))

    IFS=',' read -r -a box_chars <<< "$(get_box_chars "$box_type")" 

    printf "${On_Cyan}%s%s%s${NC}\n" "${box_chars[4]}" "$(center_text "$title" $((box_width - 2)))" "${box_chars[5]}"

}

# draw a single line, this is pretty much <HR>
# usage: draw_a_line <BoxType> <BgColor>
draw_a_line() {
    local width=$BOX_WIDTH
    local box_type=${1:-'FULL'}
    local bg_color=${2:-${CYAN}}
    local box_chars

    IFS=',' read -r -a box_chars <<< "$(get_box_chars "$box_type")" 

    draw_box_line "$width" "$bg_color" "${box_chars[6]}" "${box_chars[7]}" "${box_chars[8]}" "false"
}