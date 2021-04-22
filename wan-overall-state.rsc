# wanhealththing
# Determination of overall situation with WAN

:global isp1gw
:global isp2gw
:global isp3gw
:global extmon1
:global extmon2
:global extmon3
:global wanoverallstate 
:global abnormalstate

:set wanoverallstate ($isp1gw + $isp2gw + $isp3gw + $extmon1 + $extmon2 + $extmon3)

    :if (\$wanoverallstate < 3) do={
        :log warning "WAN Overall state is abnormaly low... trying to reload netwatch metrics..."
        /tool netwatch set disabled=yes [find where comment~"^wanhealththing"]
        :delay 1
        /tool netwatch set disabled=no [find where comment~"^wanhealththing"]
        :log warning "Netwatch metrics reloaded!"
        :set $abnormalstate ($abnormalstate + 1)
    }
