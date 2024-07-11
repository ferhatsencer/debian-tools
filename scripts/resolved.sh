#!/usr/bin/env bash

# Configuration to add
config=$(cat <<EOF
#added by user
# Configure Quad9 DNS servers
#DNS=9.9.9.9 149.112.112.112 2620:fe::fe 2620:fe::9
#DNS=9.9.9.9#dns.quad9.net 149.112.112.112#dns.quad9.net 2620:fe::fe#dns.quad9.net 2620:fe::9#dns.quad9.net

#added by user - mullvad
#DNS=194.242.2.2#dns.mullvad.net
#DNS=194.242.2.3#adblock.dns.mullvad.net
#DNS=194.242.2.4#base.dns.mullvad.net
#DNS=194.242.2.5#extended.dns.mullvad.net
#DNS=194.242.2.9#all.dns.mullvad.net
#DNSSEC=no
#DNSOverTLS=yes
#Domains=~.

#added by user libredns
#DNS without adblock
#DNS=116.202.176.26#dot.libredns.gr
#DNS with adblock
#DNS=116.202.176.26#noads.libredns.gr
#FallbackDNS=127.0.0.1 ::1
#DNSOverTLS=yes

#DNS=
#FallbackDNS=
#Domains=
#DNSSEC=no
#DNSOverTLS=no
#MulticastDNS=yes
#LLMNR=yes
#Cache=yes
#CacheFromLocalhost=no
#DNSStubListener=yes
#DNSStubListenerExtra=
#ReadEtcHosts=yes
#ResolveUnicastSingleLabel=no
EOF
)

# Prompt user for confirmation
read -p "Do you want to add the configuration to /etc/systemd/resolved.conf? [y/N]: " proceed
if [[ "$proceed" != [yY] ]]; then
    echo "Configuration not added. Exiting."
    exit 0
fi

# Check if the file exists
if [ -f "/etc/systemd/resolved.conf" ]; then
    # Append configuration to the file
    sudo echo "$config" | tee -a /etc/systemd/resolved.conf > /dev/null
    echo "Configuration added to /etc/systemd/resolved.conf"
    if sudo systemctl restart systemd-resolved; then
        echo "systemd-resolved service restarted successfully"
    else
        echo "Failed to restart systemd-resolved service"
        exit 1
    fi
else
    echo "Error: /etc/systemd/resolved.conf does not exist."
    exit 1
fi
