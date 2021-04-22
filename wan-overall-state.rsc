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
:global currentISP
:global nextbackupISP
:global wanispstate
:global wanmonstate

:set $wanispstate ($isp1gw + $isp2gw + $isp3gw)
:set $wanmonstate ($extmon1 + $extmon2 + $extmon3)
:set $wanoverallstate ($wanispstate + $wanmonstate)

    :if ($wanoverallstate < 6) do={
        :if ($wanoverallstate < 3) do={
            :if ($abnormalcounter <= 3) do={
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

            # Decrease abnormalcounter when all is good with netwatch metrics
            :if ($abnormalcounter > 0) do={
            :set $abnormalcounter ($abnormalcounter - 1)

            # Actions when something was happened with ISP gateway
            :if ($wanispstate < 3) do={
                #check each ISP
                system script run isp-determ
                
                # Check ISP1
                :if ($currentISP = "ISP1" && $isp1gw = 0) do={
                    :set $currentISP ($nextbackupISP)
                    :set $nextbackupISP "none"
                    :log warning "Default ISP was changed to $nextbackupISP"
                } else={
                    # Check ISP2
                    :if ($currentISP = "ISP2" && $isp2gw = 0) do={
                        :set $currentISP ($nextbackupISP)
                        :set $nextbackupISP "none"
                        :log warning "Default ISP was changed to $nextbackupISP"
                    } 
                    } else={
                        # Check ISP3
                        :if ($currentISP = "ISP3" && $isp3gw = 0) do={
                            :set $currentISP ($nextbackupISP)
                            :set $nextbackupISP "none"
                            :log warning "Default ISP was changed to $nextbackupISP"
                            #need to determine new nextbackup
                        }
                }
            # Actions when with ISP gate is OK, but something was happened with external monitored hosts
            } else={
                :if ($wanmonstate < 2) do={
                    # change to next backup
                    # determine next backup
                } else={
                    # At this moment, all seems to be great with external hosts, so just waiting for recheck.
                    # Perhaps this event-point must be counted
                }
            }
            }
        }
    } else={
        # WAN health is great!
    }