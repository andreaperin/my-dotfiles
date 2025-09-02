# check weather
weather() {
    city="$1"
    
    if [ -z "$city" ]; then
        city="Hannover,Germany"
    fi
    
    eval "curl http://wttr.in/${city}"
}