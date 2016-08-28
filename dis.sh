#!/system/bin/sh
#DIS v0.1.0 - Deic's Init.d Support

INITIAL_SCRIPT(){
    if [ "$0" == /data/dis ] || [ "$0" == data/dis ]; then
        MAIN_SCRIPT
    else
        if [ "$LANG" == ES ]; then
            echo Copiando DIS a /data...
        else
            echo Copying DIS to /data...
        fi
        sleep 1
        if cp -f $0 /data/dis; then
            chmod 755 /data/dis
            if [ "$LANG" == ES ]; then
                echo Ejecutando DIS desde /data...
            else
                echo Running DIS from /data...
            fi
            sleep 1
            sh /data/dis
        fi
    fi
}

MAIN_SCRIPT(){
    while clear; do
        for i in $DIS_FILES/*; do
            if [ -f $i ]; then
                INITD_BACKUP=1
            fi
        done
        echo $TITLE
        echo
        echo Menu:
        if [ "$LANG" == ES ]; then
            if [ "$INITD_BACKUP" == 1 ]; then
                echo "1|Instalar soporte Init.d y restaurar archivos"
            else
                echo "1|Instalar soporte Init.d"
            fi
            echo "2|Respaldar archivos de Init.d"
            echo "3|Salir"
        else
            if [ "$INITD_BACKUP" == 1 ]; then
                echo "1|Install Init.d support & restore files"
            else
                echo "1|Install Init.d support"
            fi
            echo "2|Backup files of Init.d"
            echo "3|Exit"
        fi
        busybox stty cbreak -echo
        i=$(dd bs=1 count=1 2>/dev/null)
        busybox stty -cbreak echo
        case $i in
            1)
                PRE_INSTALL_SCRIPT
            ;;
            2)
                BACKUP_SCRIPT
            ;;
            3)
                clear
                exit
            ;;
            *)
                if [ "$LANG" == ES ]; then
                    echo Opcion desconocida.
                else
                    echo Unknown option.
                fi
                sleep 1
            ;;
        esac
    done
}

PRE_INSTALL_SCRIPT(){
    mount -w -o remount /system
    if [ ! -f $BIN_ORIG ]; then
        if mv $BIN $BIN_ORIG; then
            INSTALL_SCRIPT
        fi
    else
        INSTALL_SCRIPT
    fi
}

INSTALL_SCRIPT(){
    clear
    echo $TITLE
    echo
    if [ "$LANG" == ES ]; then
        echo Instalando DIS...
    else
        echo Installing DIS...
    fi
    sleep 1
    cat > $BIN <<EOF
#!/system/bin/sh
#$TITLE

if [ "replace1" == 1 ]; then
    $BIN_ORIG
else
    $BIN_ORIG &
    sleep 30
    mount -w -o remount /system
    if [ ! -d $INITD ]; then
        mkdir -p $INITD
    fi
    cat > $INITD/00DIS_TEST <<EOF
#!/system/bin/sh
#$TITLE

date "+- %d/%m/%y - %H:%M:%S > Running test..."
echo Init.d works!
setprop initd_support_enabled 1
replace2
    if [ ! -f /data/initd.log ]; then
        touch /data/initd.log
    fi
    chmod 755 /data/initd.log
    chmod -R 755 $INITD
    exec &>/data/initd.log
    for i in $INITD/*; do
        sh replace3
    done
    if [ ! -d $DIS_FILES ]; then
        mkdir -p $DIS_FILES
    fi
    for i in $INITD/*; do
        cp -f replace3 $DIS_FILES
    done
    rm -f $DIS_FILES/00DIS_TEST
    mount -r -o remount /system 2>/dev/null
fi
EOF
    busybox sed -i 's/replace1/$(getprop initd_support_enabled)/' $BIN
    busybox sed -i 's/replace2/EOF/' $BIN
    busybox sed -i 's/replace3/$i/' $BIN
    chmod 755 $BIN
    chown root:shell $BIN
    if [ "$INITD_BACKUP" == 1 ]; then
        if [ "$LANG" == ES ]; then
            echo Restaurando archivos de Init.d...
        else
            echo Restoring files of Init.d...
        fi
        sleep 1
        for i in $DIS_FILES/*; do
            cp -f $i $INITD/
        done
    fi
    mount -r -o remount /system 2>/dev/null
    if [ "$LANG" == ES ]; then
        echo DIS fue instalado.
        echo
        echo Cuando actualices tu ROM perderas el soporte Init.d.
        echo Escribe \"data/dis\" desde el terminal para volver a instalarlo.
        echo
        echo Presiona cualquier tecla para continuar...
    else
        echo DIS was installed.
        echo
        echo When will update your ROM lose Init.d support.
        echo Type \"data/dis\" from terminal to install it again.
        echo
        echo Press any key to continue...
    fi
    busybox stty cbreak -echo
    i=$(dd bs=1 count=1 2>/dev/null)
    busybox stty -cbreak echo
}

BACKUP_SCRIPT(){
    mount -w -o remount /system
    clear
    echo $TITLE
    echo
    if [ "$LANG" == ES ]; then
        echo Respaldando archivos de Init.d...
    else
        echo Backing up files of Init.d...
    fi
    sleep 1
    if [ ! -d $DIS_FILES ]; then
        mkdir -p $DIS_FILES
    fi
    for i in $INITD/*; do
        cp -f $i $DIS_FILES
    done
    rm -f $DIS_FILES/00DIS_TEST
    mount -r -o remount /system 2>/dev/null
    if [ "$LANG" == ES ]; then
        echo Respaldo hecho.
    else
        echo Backup done.
    fi
    sleep 1
}

clear
DIS_FILES=/data/local/DIS_FILES
BIN_ORIG=/system/bin/debuggerd_original
BIN=/system/bin/debuggerd
INITD=/system/etc/init.d
TITLE="DIS v0.1.0 - Deic's Init.d Support"
if [ "$(getprop persist.sys.language)" == es ]; then
    LANG=ES
fi
echo $TITLE
echo
sleep 1
if [ "$USER" == root ]; then
    INITIAL_SCRIPT
else
    if [ "$LANG" == ES ]; then
        echo Necesitas ser usuario root para ejecutar este archivo.
        echo
        echo Escribe \"su\" y despues vuelve a intentarlo.
        echo
    else
        echo Need to be root user to run this file.
        echo
        echo Type \"su\" and try again.
        echo
    fi
fi
