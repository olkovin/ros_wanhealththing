# wanhealththing
# Determination of overall situation with WAN

:global isp1gw
:global isp2gw
:global isp3gw
:global extmon1
:global extmon2
:global extmon3
:global wanoverallstate
:global wanispstate
:global wanmonstate
:global abnormalcounter
:local currentISP
:local 1backupISP
:local 2backupISP


:set $wanispstate ($isp1gw + $isp2gw + $isp3gw)
:set $wanmonstate ($extmon1 + $extmon2 + $extmon3)
:set $wanoverallstate ($wanispstate + $wanmonstate)

    :if ($wanoverallstate != 6) do={
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
            }
                #:log warning "DEBUG POINT 1";
                # Determing current ISP priority
                :set $currentISP ([:pick [ip route get value-name=comment number=[find where distance=11 && comment~"DRV"]] 0 7]);
                :set $1backupISP ([:pick [ip route get value-name=comment number=[find where distance=22 && comment~"DRV"]] 0 7]);
                :set $2backupISP ([:pick [ip route get value-name=comment number=[find where distance=33 && comment~"DRV"]] 0 7]);
                #:log warning "DEBUG POINT 2";
             # Actions when something was happened with ISP gateway
                :if ($wanispstate != 3) do={
                   # Check ISP1
                  :if ($currentISP = "DRVISP1" && $isp1gw = 0) do={
                      # Change IPS pririty
                      # debug:
                      :log warning "DEBUG: Switching ISP when ISP1 health is BAD!"
                       ip route set distance=33 [find where comment~"$currentISP"]
                       ip route set distance=22 [find where comment~"$2backupISP"]
                       ip route set distance=11 [find where comment~"$1backupISP"]
                       #need tp change ISP using ISPstates
                       :log info "currentISP was changed to $1backupISP"
                        :log info "1backupISP was changed to $2backupISP"
                        :log info "2backupISP was changed to $currentISP"
                    } else={
                       # Check ISP2
                       :if ($currentISP = "DRVISP2" && $isp2gw = 0) do={
                         # Change IPS pririty
                          # debug:
                          :log warning "DEBUG: Switching ISP when ISP2 health is BAD!"
                           ip route set distance=33 [find where comment~"$currentISP"]
                           ip route set distance=22 [find where comment~"$2backupISP"]
                           ip route set distance=11 [find where comment~"$1backupISP"]
                           #need tp change ISP using ISPstates
                           :log info "currentISP was changed to $1backupISP"
                           :log info "1backupISP was changed to $2backupISP"
                           :log info "2backupISP was changed to $currentISP"
                      } else={
                        # Check ISP3
                        :if ($currentISP = "DRVISP3" && $isp3gw = 0) do={
                            # Change IPS pririty
                            # debug:
                            :log warning "DEBUG: Switching ISP when ISP3 health is BAD!"
                            ip route set distance=33 [find where comment~"$currentISP"]
                            ip route set distance=22 [find where comment~"$2backupISP"]
                            ip route set distance=11 [find where comment~"$1backupISP"]
                            # Informing about changes
                            :log info "currentISP was changed to $1backupISP"
                            :log info "1backupISP was changed to $2backupISP"
                            :log info "2backupISP was changed to $currentISP"
                        }
                     }
                }
                #:log warning "DEBUG POINT 3"
                # Actions when with ISP gate is OK, but something was happened with external monitored hosts
                } else={
                    :if ($wanmonstate < 2) do={
                        #debug: 
                        :log warning "DEBUG: test $currentISP"
                        :log warning "DEBUG: switching ISP when monitored host health is BAD!"
                        ip route set distance=33 [find where comment~"$currentISP"]
                        ip route set distance=22 [find where comment~"$2backupISP"]
                        ip route set distance=11 [find where comment~"$1backupISP"]
                     # Informing about changes
                        :log info "currentISP was changed to $1backupISP"
                        :log info "1backupISP was changed to $2backupISP"
                        :log info "2backupISP was changed to $currentISP"
                    } else={
                        # At this moment, all seems to be great with external hosts, so just waiting for recheck.
                        # Perhaps this event-point must be counted
                        # debug:
                        :log warning "DEBUG: Anomaly. Trigered bad monitored hosts event, but now all ok!"
                    }
                }
        }
    } else={
        # WAN health is great!
        # debug:
        #:log info "DEBUG: WAN health is great!"
    }