# Router OS WANhealththing
# t.me/olekovin
# github.com/olkovin/ros_wanhealththing
# Part of the overall script group
# Device ISP state determinator part

# Global vars
:global ISP1present
:global ISP2present
:global ISP2present
:global ISP1hp
:global ISP2hp
:global ISP3hp
:global healthcheck1
:global healthcheck2
:global healthcheck3
:global pinginterval
:global pingcount
:global DebugIsOn

# Checking if there is pinging parameters set
# If not, setting to default
:if ($pinginterval = nothing) do={
    :set $pinginterval "0.5"

    # Displaying debug info, if DebuIsOn True
    :if ($DebugIsOn) do={
        :log warning ""
        :log warning "row-wht_isp-checker:  Used default pinginterval = $pinginterval"
        :log warning ""
    }
}

:if ($pingcount = nothing) do={
    :set $pingcount "4"

    # Displaying debug info, if DebuIsOn True
    :if ($DebugIsOn) do={
        :log warning ""
        :log warning "row-wht_isp-checker:  Used default pingcount = $pingcount"
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
    :set $ISP1partialstate1 [/ping $healthcheck1 interval=$pinginterval count=$pingcount routing-table=isp1-hc-table] 
    :set $ISP1partialstate2 [/ping $healthcheck2 interval=$pinginterval count=$pingcount routing-table=isp1-hc-table]
    :set $ISP1partialstate3 [/ping $healthcheck3 interval=$pinginterval count=$pingcount routing-table=isp1-hc-table]
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
    :set $ISP2partialstate1 [/ping $healthcheck1 interval=$pinginterval count=$pingcount routing-table=isp2-hc-table] 
    :set $ISP2partialstate2 [/ping $healthcheck2 interval=$pinginterval count=$pingcount routing-table=isp2-hc-table]
    :set $ISP2partialstate3 [/ping $healthcheck3 interval=$pinginterval count=$pingcount routing-table=isp2-hc-table]
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

    # Local vars
    :local ISP3partialstate1
    :local ISP3partialstate2
    :local ISP3partialstate3

    # Checking the healthchecks and setting the ISPstate
    :set $ISP3partialstate1 [/ping $healthcheck1 interval=$pinginterval count=$pingcount routing-table=isp3-hc-table] 
    :set $ISP3partialstate2 [/ping $healthcheck2 interval=$pinginterval count=$pingcount routing-table=isp3-hc-table]
    :set $ISP3partialstate3 [/ping $healthcheck3 interval=$pinginterval count=$pingcount routing-table=isp3-hc-table]
    :set $ISP3hp ($ISP3partialstate1+$ISP3partialstate2+$ISP3partialstate3)

    } else={
            # Displaying debug info, if DebuIsOn True
            :if ($DebugIsOn) do={
                :log warning ""
                :log warning "row-wht_isp-checker:  There is no ISP3 configured. Skipping and setting the ISP3hp to 0."
                :log warning ""
            }
            :set $ISP3hp 0
    }