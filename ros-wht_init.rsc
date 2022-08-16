# Router OS WANhealththing
# t.me/olekovin
#
# Part of the overall script group
# ISP Actioner part

# Part of the overall script group
# Provider count and type determinator part
#
# !!!Will determine only on boot!!!
# init script. will start on boot
# ros-wht_init

# Global vars
:global ISP1present
:global ISP2present
:global ISP3present
:global ISP1type
:global ISP2type
:global ISP3type
:global DebugIsOn

################
# ISPs types and count determinator v3
#
# Local vars
:local ISP1probeTypeStatic [/ip address print as-value count-only where comment="ISP1" && disabled=no]
:local ISP2probeTypeStatic [/ip address print as-value count-only where comment="ISP2" && disabled=no]
:local ISP3probeTypeStatic [/ip address print as-value count-only where comment="ISP3" && disabled=no]
:local ISP1probeTypeDynamic [/ip dhcp-client print as-value count-only where comment="ISP1" && disabled=no]
:local ISP2probeTypeDynamic [/ip dhcp-client print as-value count-only where comment="ISP2" && disabled=no]
:local ISP3probeTypeDynamic [/ip dhcp-client print as-value count-only where comment="ISP3" && disabled=no]

# Firstly, temporary disable all deamons, before full init
/system scheduler set disabled=yes [find where comment~"deamon" && !(comment~"init")]

# Determining ISP1 type
:if ($ISP1probeTypeStatic = 1) do={
        #ISP1 type is Static
        :do {
            :set $ISP1present true
            :set $ISP1type "STATIC"
            } on-error={
                :log error "Error setting ISP1 type and presentage state."
                :log error "Error code: ESISP1PS_STATIC"
            }
} else={
    :if ($ISP1probeTypeDynamic = 1) do={
        #ISP1 type is DHCP
        :do {
            :set $ISP1present true
            :set $ISP1type "DHCP"
            } on-error={
                :log error "Error setting ISP1 type and presentage state."
                :log error "Error code: ESISP1PS_DCHP"
            }
    }
}

# Determining ISP2 type
:if ($ISP2probeTypeStatic = 1) do={
        #ISP2 type is Static
        :do {
            :set $ISP2present true
            :set $ISP2type "STATIC"
            } on-error={
                :log error "Error setting ISP2 type and presentage state."
                :log error "Error code: ESISP2PS_STATIC"
            }
} else={
    :if ($ISP2probeTypeDynamic = 1) do={
        #ISP2 type is DHCP
        :do {
            :set $ISP2present true
            :set $ISP2type "DHCP"
            } on-error={
                :log error "Error setting ISP2 type and presentage state."
                :log error "Error code: ESISP2PS_DCHP"
            }
    }
}

# Determining ISP2 type
:if ($ISP3probeTypeStatic = 1) do={
        #ISP3 type is Static
        :do {
            :set $ISP3present true
            :set $ISP3type "STATIC"
            } on-error={
                :log error "Error setting ISP3 type and presentage state."
                :log error "Error code: ESISP3PS_STATIC"
            }
} else={
    :if ($ISP3probeTypeDynamic = 1) do={
        #ISP3 type is DHCP
        :do {
            :set $ISP3present true
            :set $ISP3type "DHCP"
            } on-error={
                :log error "Error setting ISP3 type and presentage state."
                :log error "Error code: ESISP3PS_DCHP"
            }
    }
}

:delay 15
# And finaly, back all of the our disabled deamons back
/system scheduler set disabled=no [find where comment~"deamon" && comment~"init"]