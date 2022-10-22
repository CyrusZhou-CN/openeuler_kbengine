#!/bin/bash
cp -rf $KBE_ROOT/kbe/res/server/kbengine_defaults.xml.bak $KBE_ROOT/kbe/res/server/kbengine_defaults.xml
sed -i "s/MARIADB_HOST/$MARIADB_HOST/g" $KBE_ROOT/kbe/res/server/kbengine_defaults.xml
sed -i "s/MARIADB_PORT/$MARIADB_PORT/g" $KBE_ROOT/kbe/res/server/kbengine_defaults.xml
sed -i "s/MARIADB_DATABASE/$MARIADB_DATABASE/g" $KBE_ROOT/kbe/res/server/kbengine_defaults.xml
sed -i "s/MARIADB_USER/$MARIADB_USER/g" $KBE_ROOT/kbe/res/server/kbengine_defaults.xml
sed -i "s/MARIADB_PASSWORD/$MARIADB_PASSWORD/g" $KBE_ROOT/kbe/res/server/kbengine_defaults.xml

cp -rf $KBE_ROOT/assets/res/server/kbengine.xml.bak $KBE_ROOT/assets/res/server/kbengine.xml
sed -i "s/MARIADB_HOST/$MARIADB_HOST/g" $KBE_ROOT/assets/res/server/kbengine.xml
sed -i "s/MARIADB_PORT/$MARIADB_PORT/g" $KBE_ROOT/assets/res/server/kbengine.xml
sed -i "s/MARIADB_DATABASE/$MARIADB_DATABASE/g" $KBE_ROOT/assets/res/server/kbengine.xml
sed -i "s/MARIADB_USER/$MARIADB_USER/g" $KBE_ROOT/assets/res/server/kbengine.xml
sed -i "s/MARIADB_PASSWORD/$MARIADB_PASSWORD/g" $KBE_ROOT/assets/res/server/kbengine.xml

cp -rf $KBE_ROOT/kbe/tools/server/webconsole/KBESettings/settings.py.bak $KBE_ROOT/kbe/tools/server/webconsole/KBESettings/settings.py
sed -i "s/MARIADB_HOST/$MARIADB_HOST/g" $KBE_ROOT/kbe/tools/server/webconsole/KBESettings/settings.py
sed -i "s/MARIADB_PORT/$MARIADB_PORT/g" $KBE_ROOT/kbe/tools/server/webconsole/KBESettings/settings.py
sed -i "s/MARIADB_DATABASE/$MARIADB_DATABASE/g" $KBE_ROOT/kbe/tools/server/webconsole/KBESettings/settings.py
sed -i "s/MARIADB_USER/$MARIADB_USER/g" $KBE_ROOT/kbe/tools/server/webconsole/KBESettings/settings.py
sed -i "s/MARIADB_PASSWORD/$MARIADB_PASSWORD/g" $KBE_ROOT/kbe/tools/server/webconsole/KBESettings/settings.py


cd $KBE_ROOT/assets/
sh ./start_server.sh
python $KBE_ROOT/kbe/tools/server/pycluster/cluster_controller.py
ps -ef | grep kbe
sh ./watchlog.sh
#python $KBE_ROOT/kbe/tools/server/pycluster/cluster_controller.py query
echo -e "\033[32m ==> START SUCCESSFUL \033[0m"
cd $KBE_ROOT/kbe/tools/server/webconsole
sh ./run_server.sh
waitterm() {
        local PID
        # any process to block
        tail -f /dev/null &
        PID="$!"
        # setup trap, could do nothing, or just kill the blocker
        trap "kill -TERM ${PID}" TERM INT
        # wait for signal, ignore wait exit code
        wait "${PID}" || true
        # clear trap
        trap - TERM INT
        # wait blocker, ignore blocker exit code
        wait "${PID}" 2>/dev/null || true
}
waitterm

echo "==> STOP"
python $KBE_ROOT/kbe/tools/server/pycluster/cluster_controller.py stop
echo "==> STOP SUCCESSFUL ..."