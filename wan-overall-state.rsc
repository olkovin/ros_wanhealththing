# wanhealththing
# Determination of overall situation with WAN

:global isp1gw
:global isp2gw
:global isp3gw
:global extmon1
:global extmon2
:global extmon3
:global wanoverallstate 
:global abnormalcounter

:set $wanoverallstate ($isp1gw + $isp2gw + $isp3gw + $extmon1 + $extmon2 + $extmon3)

    :if ($wanoverallstate < 3) do={
        :if ($abnormalcounter < 3) do={
            :log warning "WAN Overall state is abnormaly low... trying to reload netwatch metrics..."
            /tool netwatch set disabled=yes [find where comment~"^wanhealththing"]
            :delay 1
            /tool netwatch set disabled=no [find where comment~"^wanhealththing"]
            :log warning "Netwatch metrics reloaded!"
            :set $abnormalcounter ($abnormalcounter + 1)
        } else={
                :if ($abnormalcounter > 3) do={
                :log error "Error! After couple netwatch metric reloads, WAN overall state is still abnormal. Slow mode enabled."
                # some slow check need to be activated
            }
        }
    } else={
        :set $abnormalcounter ($abnormalcounter - 1)
    }