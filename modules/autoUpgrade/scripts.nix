{
    pkgs,
    ...
}:
{
    # Send a desktop notification upon build confirmation request
    notifier-build = pkgs.writers.writeBashBin "notifier-build" ''
        # bash
        NOTIFY_TITLE=$1
        NOTIFY_URGENCY=$2
        NOTIFY_MESSAGE=$3
        NOTIFY_ACTION=$4

        for id in $(loginctl list-sessions -j | ${pkgs.jq}/bin/jq -r '.[] | .session') ; do
            if [[ $(loginctl show-session "$id" --property=Type) =~ (wayland|x11) ]] ; then
                USER=$(loginctl show-session "$id" --property=Name --value)
                if [ ! -e "/home/$USER/.local/share/comin-build" ] || [ ! "$(cat "/home/$USER/.local/share/comin-build")" == "$(echo "$(comin status --json)" | ${pkgs.jq}/bin/jq .build_confirmer.submitted)" ]; then
                    comin status --json | ${pkgs.jq}/bin/jq .build_confirmer.submitted > "/home/$USER/.local/share/comin-build"
                    COMMIT=$(comin status --json | ${pkgs.jq}/bin/jq ".builder.generation.selected_commit_msg | trimstr(\"\n\")")
                    RESPONSE=$(sudo -u "$USER" DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$(id -u "$USER")"/bus ${pkgs.libnotify}/bin/notify-send --urgency="$NOTIFY_URGENCY" --app-name="$NOTIFY_TITLE" --action=update="$NOTIFY_ACTION" "$NOTIFY_MESSAGE" "Commit: $COMMIT")
                    if [ "$RESPONSE" == "update" ]; then
                        comin confirmation accept
                    fi
                fi
            fi
        done
    '';

    # Send a desktop notification upon deploy confirmation request
    notifier-deploy = pkgs.writers.writeBashBin "notifier-deploy" ''
        # bash
        NOTIFY_TITLE=$1
        NOTIFY_URGENCY=$2
        NOTIFY_MESSAGE=$3
        NOTIFY_ACTION=$4

        for id in $(loginctl list-sessions -j | ${pkgs.jq}/bin/jq -r '.[] | .session') ; do
            if [[ $(loginctl show-session "$id" --property=Type) =~ (wayland|x11) ]] ; then
                USER=$(loginctl show-session "$id" --property=Name --value)
                if [ ! -e "/home/$USER/.local/share/comin-deployment" ] || [ ! "$(cat "/home/$USER/.local/share/comin-deployment")" == "$(echo "$(comin status --json)" | ${pkgs.jq}/bin/jq .deploy_confirmer.submitted)" ]; then
                    comin status --json | ${pkgs.jq}/bin/jq .deploy_confirmer.submitted > "/home/$USER/.local/share/comin-deployment"
                    COMMIT=$(comin status --json | ${pkgs.jq}/bin/jq ".builder.generation.selected_commit_msg | trimstr(\"\n\")")
                    RESPONSE=$(sudo -u "$USER" DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$(id -u "$USER")"/bus ${pkgs.libnotify}/bin/notify-send --urgency="$NOTIFY_URGENCY" --app-name="$NOTIFY_TITLE" --action=update="$NOTIFY_ACTION" "$NOTIFY_MESSAGE" "Commit: $COMMIT")
                    if [ "$RESPONSE" == "update" ]; then
                        comin confirmation accept
                    fi
                fi
            fi
        done
    '';

    # Send a desktop notification when a reboot is required
    notifier-reboot = pkgs.writers.writeBashBin "notifier-reboot" ''
        # bash
        NOTIFY_TITLE=$1
        NOTIFY_URGENCY=$2
        NOTIFY_MESSAGE=$3
        NOTIFY_ACTION=$4

        for id in $(loginctl list-sessions -j | ${pkgs.jq}/bin/jq -r '.[] | .session') ; do
            if [[ $(loginctl show-session "$id" --property=Type) =~ (wayland|x11) ]] ; then
                USER=$(loginctl show-session "$id" --property=Name --value)
                RESPONSE=$(sudo -u "$USER" DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$(id -u "$USER")"/bus ${pkgs.libnotify}/bin/notify-send --urgency="$NOTIFY_URGENCY" --app-name="$NOTIFY_TITLE" --action=reboot="$NOTIFY_ACTION" "$NOTIFY_MESSAGE" "The system is out of date and needs to be rebooted!")
                if [ "$RESPONSE" == "reboot" ]; then
                    shutdown -r now
                fi
            fi
        done
    '';
}
