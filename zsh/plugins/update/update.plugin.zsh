if [ -f /etc/os-release ]; then
    . /etc/os-release

    case $NAME in

        'Solus')
            alias update='sudo eopkg up'
            install() {
                eval 'sudo eopkg it ${1}'
            }
            remove() {
                eval 'sudo eopkg remove ${1}'
            }
        ;;

        'Ubuntu')
            alias update='sudo apt update; sudo apt upgrade'
            install() {
                eval 'sudo apt install ${1}'
            }
            remove() {
                eval 'sudo apt remove ${1}'
            }
        ;;
    esac
fi
