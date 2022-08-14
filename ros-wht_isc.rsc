# Router OS WANhealththing
# t.me/olekovin
# github.com/olkovin/ros_wanhealththing
# Part of the overall script group
# Device ISP state determinator part
# ros-wht_isc

# Global vars
:global ISP1present
:global ISP2present
:global ISP2present
:global ISP1hp
:global ISP2hp
:global ISP3hp

# You can change it to whatever host you want to use as healthcheck
# If there is default, 1.1.1.1, 9.9.9.9 and 8.8.8.8 will be used in healthcheck 
:global HCaddr1 "default"
:global HCaddr2 "default"
:global HCaddr3 "default"

# You can change ping interval and pings count to whatever you need
# Default values is 0.5s for ping interval and 4 for the pingscount
# Hint: lowering interval is more suitable for more stable connections
# Hint: 
:global pingsinterval "default"
:global pingscount "default"
:global DebugIsOn


# Duplication run handler
# Check if checker is already running now, dont do anything.
:if ([/system script job print as-value count-only where script="ros-wht_isc"] <= 1) do={

# Checking if there are pinging parameters and healthchecks was set
# If not, setting to default
:if ($pingsinterval = "default") do={
    :set $pingsinterval "0.5"

    # Displaying debug info, if DebuIsOn True
    :if ($DebugIsOn) do={
        :log warning ""
        :log warning "row-wht_isp-checker:  Used default pingsinterval = $pingsinterval"
        :log warning ""
    }
}

:if ($pingscount = "default") do={
    :set $pingscount "4"

    # Displaying debug info, if DebuIsOn True
    :if ($DebugIsOn) do={
        :log warning ""
        :log warning "row-wht_isp-checker:  Used default pingscount = $pingscount"
        :log warning ""
    }
}

:if ($HCaddr1 = "default") do={
    :set $HCaddr1 "1.1.1.1"

        # Displaying debug info, if DebuIsOn True
    :if ($DebugIsOn) do={
        :log warning ""
        :log warning "row-wht_isp-checker:  Used default HCaddr1 = $HCaddr1"
        :log warning ""
    }
}

:if ($HCaddr2 = "default") do={
    :set $HCaddr2 "9.9.9.9"

        # Displaying debug info, if DebuIsOn True
    :if ($DebugIsOn) do={
        :log warning ""
        :log warning "row-wht_isp-checker:  Used default HCaddr2 = $HCaddr2"
        :log warning ""
    }
}

:if ($HCaddr3 = "default") do={
    :set $HCaddr3 "8.8.8.8"

        # Displaying debug info, if DebuIsOn True
    :if ($DebugIsOn) do={
        :log warning ""
        :log warning "row-wht_isp-checker:  Used default HCaddr3 = $HCaddr3"
        :log warning ""
    }
}

### Passing state of the providers getted from netwatch to global vars
    # Passing state of the ISP1
    :if ($ISP1present) do={

    # Local vars
    :local ISP1partialstate1
    :local ISP1partialstate2
    :local ISP1partialstate3

    # Checking the healthchecks and setting the ISPstate
    :set $ISP1partialstate1 [/ping $HCaddr1 interval=$pingsinterval count=$pingscount routing-table=isp1-hc-table] 
    :set $ISP1partialstate2 [/ping $HCaddr2 interval=$pingsinterval count=$pingscount routing-table=isp1-hc-table]
    :set $ISP1partialstate3 [/ping $HCaddr3 interval=$pingsinterval count=$pingscount routing-table=isp1-hc-table]

    :set $ISP1hp ($ISP1partialstate1+$ISP1partialstate2+$ISP1partialstate3)

    } else={
            # Displaying debug info, if DebuIsOn True
            :if ($DebugIsOn) do={
                :log warning ""
                :log warning "row-wht_isp-checker:  There is no ISP1 configured. Skipping and setting the ISP1hp to 0."
                :log warning ""
            }
            :set $ISP1hp 0
    }

    # Passing state of the ISP2
    :if ($ISP2present) do={

    # Local vars
    :local ISP2partialstate1
    :local ISP2partialstate2
    :local ISP2partialstate3

    # Checking the healthchecks and setting the ISPstate
    :set $ISP2partialstate1 [/ping $HCaddr1 interval=$pingsinterval count=$pingscount routing-table=isp2-hc-table] 
    :set $ISP2partialstate2 [/ping $HCaddr2 interval=$pingsinterval count=$pingscount routing-table=isp2-hc-table]
    :set $ISP2partialstate3 [/ping $HCaddr3 interval=$pingsinterval count=$pingscount routing-table=isp2-hc-table]
    :set $ISP2hp ($ISP2partialstate1+$ISP2partialstate2+$ISP2partialstate3)

    } else={
            # Displaying debug info, if DebuIsOn True
            :if ($DebugIsOn) do={
                :log warning ""
                :log warning "row-wht_isp-checker:  There is no ISP2 configured. Skipping and setting the ISP2hp to 0."
                :log warning ""
            }
            :set $ISP2hp 0
    }

    # Passing state of the ISP3
    :if ($ISP3present) do={

    # Local vars
    :local ISP3partialstate1
    :local ISP3partialstate2
    :local ISP3partialstate3

    # Checking the healthchecks and setting the ISPstate
    :set $ISP3partialstate1 [/ping $HCaddr1 interval=$pingsinterval count=$pingscount routing-table=isp3-hc-table] 
    :set $ISP3partialstate2 [/ping $HCaddr2 interval=$pingsinterval count=$pingscount routing-table=isp3-hc-table]
    :set $ISP3partialstate3 [/ping $HCaddr3 interval=$pingsinterval count=$pingscount routing-table=isp3-hc-table]
    :set $ISP3hp ($ISP3partialstate1+$ISP3partialstate2+$ISP3partialstate3)

    } else={
            # Displaying debug info, if DebuIsOn True
            :if ($DebugIsOn) do={
                :log warning ""
                :log warning "row-wht_isp-checker:  There is no ISP3 configured. Skipping and setting the ISP2hp to 0."
                :log warning ""
            }
            :set $ISP3hp 0
    }
}