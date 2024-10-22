#!/bin/bash

set -e

if [ -v PASSWORD_FILE ]; then
    PASSWORD="$(< $PASSWORD_FILE)"
fi

# set the postgres database host, port, user and password according to the environment
# and pass them as arguments to the odoo process if not present in the config file
: ${HOST:=${DB_PORT_5432_TCP_ADDR:='db'}}
: ${PORT:=${DB_PORT_5432_TCP_PORT:=5432}}
: ${USER:=${DB_ENV_POSTGRES_USER:=${POSTGRES_USER:='odoo'}}}
: ${PASSWORD:=${DB_ENV_POSTGRES_PASSWORD:=${POSTGRES_PASSWORD:='odoo'}}}

# Hide specific menu in user menu
# sed cmd file > tmp; cat tmp > file; rm tmp
echo "Customize Usermenu ..."
sed '/id: "documentation",/a hide: "true",' /usr/lib/python3/dist-packages/odoo/addons/web/static/src/webclient/user_menu/user_menu_items.js > tmp; cat tmp > /usr/lib/python3/dist-packages/odoo/addons/web/static/src/webclient/user_menu/user_menu_items.js; rm tmp
sed '/id: "support",/a hide: "true",' /usr/lib/python3/dist-packages/odoo/addons/web/static/src/webclient/user_menu/user_menu_items.js > tmp; cat tmp > /usr/lib/python3/dist-packages/odoo/addons/web/static/src/webclient/user_menu/user_menu_items.js; rm tmp
sed '/id: "settings",/a hide: "true",' /usr/lib/python3/dist-packages/odoo/addons/web/static/src/webclient/user_menu/user_menu_items.js > tmp; cat tmp > /usr/lib/python3/dist-packages/odoo/addons/web/static/src/webclient/user_menu/user_menu_items.js; rm tmp
sed '/id: "account",/a hide: "true",' /usr/lib/python3/dist-packages/odoo/addons/web/static/src/webclient/user_menu/user_menu_items.js > tmp; cat tmp > /usr/lib/python3/dist-packages/odoo/addons/web/static/src/webclient/user_menu/user_menu_items.js; rm tmp

echo "Text debranding ..."
files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" "Odoo" "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/\bOdoo\b/MERP/g'
files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'www.odoo.com' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/www.odoo.com/www.manzada.net/g'
files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'odoo.com' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/accounts.odoo.com/accounts.manzada.net/g'
files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'odoo@example.com' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/odoo@example.com/mail@example.com/g'
files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Negara-Negara' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Negara-Negara/Negara/g'
files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'hari-hari' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/hari-hari/hari/g'
files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Vendor Terbai' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Vendor Terbai/Vendor Terbaik/g'
files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Vendor Terbaikk' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Vendor Terbaikk/Vendor Terbaik/g'
files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Kategori Produk Terbai' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Kategori Produk Terbai/Kategori Produk Terbaik/g'
files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Kategori-Kategori Terbaik' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Kategori-Kategori Terbaik/Kategori Produk Terbaik/g'
files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Salespeople Terbaik' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Salespeople Terbaik/Salesman Terbaik/g'
files=$(grep -rl --exclude="Read*" --exclude-dir="/usr/lib/python3/dist-packages/odoo/addons/web/static/img" 'Memerintahkan' "/usr/lib/python3/dist-packages/odoo/" | cut -f 1 -d ':' | sort | uniq) && echo $files | xargs sed -i 's/Memerintahkan/Ordered/g'

echo "Icon debranding ..."
yes | cp /etc/lambertus/img/*.png /usr/lib/python3/dist-packages/odoo/addons/web/static/img/
yes | cp /etc/lambertus/img/*.svg /usr/lib/python3/dist-packages/odoo/addons/web/static/img/
yes | cp /etc/lambertus/img/*.ico /usr/lib/python3/dist-packages/odoo/addons/web/static/img/

DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" |cut -d " " -f3|sed 's/["\n\r]//g')
    fi;
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}
check_config "db_host" "$HOST"
check_config "db_port" "$PORT"
check_config "db_user" "$USER"
check_config "db_password" "$PASSWORD"

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            wait-for-psql.py ${DB_ARGS[@]} --timeout=30
            exec odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        wait-for-psql.py ${DB_ARGS[@]} --timeout=30
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1
