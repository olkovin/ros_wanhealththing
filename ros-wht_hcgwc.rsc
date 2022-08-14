# Router OS WANhealththing
# t.me/olekovin
#
# Part of the overall script group
# HealtCheck gateway processing unit
# ros-wht_hcgwc

:global cliISP1type
:global cliISP2type
:global DebugIsOn

:if ($cliISP1type = "DHCP") do={
    :global cliISP1dhcpGW
}

:if ($cliISP2type = "DHCP") do={
    :global cliISP2dhcpGW
}


# Duplication run handler
# Check if hcgw is already running now, dont do anything.
:if ([/system script job print as-value count-only where script="rwsv-hcgw"] <= 1) do={

#
# Set HealCheck GW for ISP1 in case when ISP1 type is static
#
:if ($cliISP1type = "STATIC") do={
        # Getting current ISP1_HC_GW for comparison
        :local cliISP1currentHCGW [/ip route get value-name=gateway [find where comment~"ISP1_HC_RT"]]
        :local cliISP1staticGW [/ip route get value-name=gateway [find where comment~"ISP1_GW_RT"]]
        
        # Realising compare logic for STATIC.
        :if ($cliISP1currentHCGW != $cliISP1staticGW) do={
            # Situation when current HC GW is different with new one
            # Seting the ISP1_HC with getted cliISP1staticGW
            /ip route set gateway=$cliISP1staticGW [find where comment~"ISP1_HC_RT" && gateway!=$cliISP1staticGW]
            :if ($DebugIsOn) do={
                :log warning ""
                :log warning "rwsv-hcgw.rsc:"
                :log warning "Current ISP1_HC_GW is not the same with current cliISP1staticGW"
                :log warning "Refreshing GW for ISP1_HC_RT..."
                }
                } else={
                    :if ($cliISP1currentHCGW = $cliISP1staticGW) do={
                        # Situation when current HC GW is the SAME with new
                        :if ($DebugIsOn) do={
                            :log warning ""
                            :log warning "rwsv-hcgw.rsc:"
                            :log warning "Current ISP1_HC_GW is the same with current cliISP1staticGW"
                            :log warning "Nothing need to be done..."
                            }
                            }
                            }
} else={
    :if ($cliISP1type = "DHCP") do={
        # Getting current ISP1_HC_GW for comparison
        :local cliISP1currentHCGW [/ip route get value-name=gateway [find where comment~"ISP1_HC_RT"]]
        :global cliISP1dhcpGW
        # Realising compare logic for DHCP.
        :if ($cliISP1currentHCGW != $cliISP1dhcpGW) do={
            # Situation when current HC GW is different with new
            # Seting the ISP1_HC with getted cliISP1dhcpGW
            /ip route set gateway=$cliISP1dhcpGW [find where comment~"ISP1_HC_RT" && gateway!=cliISP1staticGW]
            :if ($DebugIsOn) do={
                :log warning ""
                :log warning "rwsv-hcgw.rsc:"
                :log warning "Current ISP1_HC_GW is not the same with current cliISP1dhcpGW"
                :log warning "Refreshing GW for ISP1_HC_RT..."
                }
                } else={
                    :if ($cliISP1currentHCGW = $cliISP1dhcpGW) do={
                        # Situation when current HC GW is the SAME with new
                        :if ($DebugIsOn) do={
                            :log warning ""
                            :log warning "rwsv-hcgw.rsc:"
                            :log warning "Current ISP1_HC_GW is the same with current cliISP1dhcpGW"
                            :log warning "Nothing need to be done..."
                            }
                            }
                            }
                            } else={
                                :log error ""
                                :log error "Error: ISP1 probably have unknown type!"
                                :log error "Error code: GWIPFHC_isp1_nonSTATIC_nonDHCP"
                                }
                                }
#
# Set HealCheck GW for ISP2 in case when ISP1 type is static
#
:if ($cliISP2type != "NONE") do={
    :if ($cliISP2type = "STATIC") do={
        # Getting current ISP2_HC_GW for comparison
        :local cliISP2currentHCGW [/ip route get value-name=gateway [find where comment~"ISP2_HC_RT"]]
        :local cliISP2staticGW [/ip route get value-name=gateway [find where comment~"ISP2_GW_RT"]]
        
        # Realising compare logic for STATIC.
        :if ($cliISP2currentHCGW != $cliISP2staticGW) do={
            # Situation when current HC GW is different with new one
            # Seting the ISP2_HC with getted cliISP2staticGW
            /ip route set gateway=$cliISP2staticGW [find where comment~"ISP2_HC_RT" && gateway!=$cliISP2staticGW]
            :if ($DebugIsOn) do={
                :log warning ""
                :log warning "rwsv-hcgw.rsc:"
                :log warning "Current ISP2_HC_GW is not the same with current cliISP2staticGW"
                :log warning "Refreshing GW for ISP2_HC_RT..."
                }
                } else={
                    :if ($cliISP2currentHCGW = $cliISP2staticGW) do={
                        # Situation when current HC GW is the SAME with new
                        :if ($DebugIsOn) do={
                            :log warning ""
                            :log warning "rwsv-hcgw.rsc:"
                            :log warning "Current ISP2_HC_GW is the same with current cliISP2staticGW"
                            :log warning "Nothing need to be done..."
                            }
                            }
                            }
    } else={
        :if ($cliISP2type = "DHCP") do={
            # Getting current ISP2_HC_GW for comparison
            :local cliISP2currentHCGW [/ip route get value-name=gateway [find where comment~"ISP2_HC_RT"]]
            :global cliISP2dhcpGW
            # Realising compare logic for DHCP.
                :if ($cliISP2currentHCGW != $cliISP2dhcpGW) do={
                    # Situation when current HC GW is different with new
                    # Seting the ISP2_HC with getted cliISP2dhcpGW
                    /ip route set gateway=$cliISP2dhcpGW [find where comment~"ISP2_HC_RT"]
                    :if ($DebugIsOn) do={
                        :log warning ""
                        :log warning "rwsv-hcgw.rsc:"
                        :log warning "Current ISP2_HC_GW is not the same with current cliISP2dhcpGW"
                        :log warning "Refreshing GW for ISP2_HC_RT..."
                        :log error "$cliISP2currentHCGW"
                        :log error "$cliISP2dhcpGW"
                        }
                        } else={
                            :if ($cliISP2currentHCGW = $cliISP2dhcpGW) do={
                                # Situation when current HC GW is the SAME with new
                                :if ($DebugIsOn) do={
                                    :log warning ""
                                    :log warning "rwsv-hcgw.rsc:"
                                    :log warning "Current ISP2_HC_GW is the same with current cliISP2dhcpGW"
                                    :log warning "Nothing need to be done..."
                                    }
                                    }
                                    }
                                } else={
                                    :log error ""
                                    :log error "Error: ISP2 probably have unknown type!"
                                    :log error "Error code: GWIPFHC_isp2_nonSTATIC_nonDHCP"
                                    }
                                    }
    
} else={
        :if ($DebugIsOn) do={
        :log warning ""
        :log warning "rwsv-hcgw.rsc:"
        :log warning "Case when here is no ISP2"
        :log warning "Nothing need to be done."
    }
}

# Get system uptime for declaring some functions
:local SysUptime [/system resource get uptime]

:if ($SysUptime < 1m) do={
    :if ($DebugIsOn) do={
        :log warning ""
        :log warning "rwsv-hcgw.rsc:"
        :log warning "SystemUptime is less than 1m"
        :log warning "Waiting 10s and turning on the deamons!"
    }
:delay 15
# And finaly, back all of the our disabled deamons back
/system scheduler set disabled=no [find where comment~"deamon" && disabled=yes]
}
} else={
        :if ($DebugIsOn) do={
        :log warning ""
        :log warning "rwsv-hcgw.rsc:"
        :log warning "SystemUptime is more than 1m"
        :log warning "So, deamons probably running already... Do nothing"
    }
}