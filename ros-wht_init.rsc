# Router OS WANhealththing
# t.me/olekovin
#
# Part of the overall script group
# Provider count and type determinator part
#
# !!!Will determine only on boot!!!
#
#
#
# ISP(X)_DGW_RT must be set on all of the ISP static routes, where (X) is the number from 1 to 3.
# e.g. ISP1_DGW_RT
# Also, ISP(X) must be set on the corresponding interfaces and DHCP-clients
# e.g. ISP1

# Debug togler
:global DebugIsOn true

# Delay in case of init on boot
:delay 5

# Firstly clear all old things from same script if debugging is ongoing
:if ($DebugIsOn) do={
    :do {
        /system scheduler remove [find where comment~"ros-wht"]
        /ip route remove [find where comment~"ros-wht" && comment~"HC" && comment~"_RT"]
        /system script environment remove [find where name!="DebugIsOn"]
        /system script job remove [find where script~"ros-wht_isc"]
        /ip route rule remove [find where comment~"ros-wht"]
        :delay 2
        
        :do {/ip dhcp-client set comment="ISP1" default-route-distance=5 [find where comment~"ISP1" && comment~"ros-wht"]} on-error={}
        :do {/ip dhcp-client set comment="ISP2" default-route-distance=6 [find where comment~"ISP2" && comment~"ros-wht"]} on-error={}
        :do {/ip dhcp-client set comment="ISP3" default-route-distance=7 [find where comment~"ISP3" && comment~"ros-wht"]} on-error={}

        :do {/ip route set comment="ISP1_DGW_RT" distance=5 [find where comment~"ISP1_DGW_RT" && comment~"ros-wht"]} on-error={}
        :do {/ip route set comment="ISP2_DGW_RT" distance=6 [find where comment~"ISP2_DGW_RT" && comment~"ros-wht"]} on-error={}
        :do {/ip route set comment="ISP3_DGW_RT" distance=7 [find where comment~"ISP3_DGW_RT" && comment~"ros-wht"]} on-error={}

        :delay 5
    } on-error={

    }
}

# You can change it to whatever host you want to use as healthcheck
# If there is default, 1.1.1.1, 9.9.9.9 and 8.8.8.8 will be used in healthcheck 
:global HCaddr1 "default"
:global HCaddr2 "default"
:global HCaddr3 "default"

# You can change ping interval and pings count to whatever you need
# Default values is 1s for ping interval and 4 for the pingscount
# Hint: lowering interval is more suitable for more stable connections
# Hint: 
:global pingsinterval "default"
:global pingscount "default"

# Global vars
:global ISP1present
:global ISP2present
:global ISP3present
:global ISP1type
:global ISP2type
:global ISP3type
:global ISPsCounter

# Local vars
:local scriptname "ros-wht_init"

# Fixining the script owner
:local currentScriptOwner [/system script get value-name=owner [find where name~"$scriptname"]]
:local correctOwner "ros-wht"

    :if ($currentScriptOwner != $correctOwner) do={
        /system script set owner=$correctOwner [find where name~"$scriptname"]
        :delay 1
        :if ($DebugIsOn) do={
        :log warning ""
        :log warning "$scriptname:  Script owner is not ros-wht"
        :log warning "$scriptname:  Changing..."
        :log warning ""
    }
    }


# Changing type of pingscount and pingsinterval
:if ($pingscount != "default") do={
    :tonum $pingscount

:if ($DebugIsOn) do={
    :log warning ""
    :log warning "$scriptname: pingscount is not default."
    :log warning "$scriptname: converting pingscount to number..."
    }

} else={
                # Checking if there are pinging parameters and healthchecks was set
            # If not, setting to default
            :if ($pingscount = "default") do={
                :set $pingscount "2"

                # Displaying debug info, if DebuIsOn True
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname:  Used default pingscount = $pingscount"
                    :log warning "$scriptname: pingscount is $pingscount"
                    :log warning ""
                }
            }
}

:if ($pingsinterval != "default") do={
    :tonum $pingsinterval

    :if ($DebugIsOn) do={
    :log warning ""
    :log warning "$scriptname: pingsinterval is not default."
    :log warning "$scriptname: converting pingsinterval to number..."
    }
} else={
            :if ($pingsinterval = "default") do={
                :set $pingsinterval "2"

                # Displaying debug info, if DebuIsOn True
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname:  Used default pingsinterval = $pingsinterval"
                    :log warning "$scriptname: pingsinterval is $pingsinterval"
                    :log warning ""
                }
            }
}

            :if ($HCaddr1 = "default") do={
                :set $HCaddr1 "1.1.1.1"

                    # Displaying debug info, if DebuIsOn True
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname:  Used default HCaddr1 = $HCaddr1"
                    :log warning ""
                }
            }

            :if ($HCaddr2 = "default") do={
                :set $HCaddr2 "9.9.9.9"

                    # Displaying debug info, if DebuIsOn True
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname:  Used default HCaddr2 = $HCaddr2"
                    :log warning ""
                }
            }

            :if ($HCaddr3 = "default") do={
                :set $HCaddr3 "8.8.8.8"

                    # Displaying debug info, if DebuIsOn True
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname:  Used default HCaddr3 = $HCaddr3"
                    :log warning ""
                }
            }

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

# Then, add init_deamon, to be sure that everythin will be started at boot
:local ROSwhtINITdeamonPresent [/system scheduler print as-value count-only where comment~"ros-wht" && comment~"init" && comment~"deamon"]
:if ($ROSwhtINITdeamonPresent != 1) do={
    /system scheduler add name="$scriptname_deamon" comment="$scriptname | init deamon | run once at boot" start-time=startup on-event="ros-wht_init"
}
###### ISP TYPES, PRESENSE AND DHCP/STATIC TUNNINGS ######

# Determining ISP1 type
:if ($ISP1probeTypeStatic = 1) do={
        #ISP1 type is Static
        :do {
            :set $ISP1present true
            :set $ISP1type "STATIC"
            } on-error={
                :log error "$scriptname: Error setting ISP1 type and presentage state."
                :log error "$scriptname: Error code: ESISP1PS_STATIC"
            }
} else={
    :if ($ISP1probeTypeDynamic = 1) do={
        #ISP1 type is DHCP
        :do {
            :set $ISP1present true
            :set $ISP1type "DHCP"
            } on-error={
                :log error "$scriptname: Error setting ISP1 type and presentage state."
                :log error "$scriptname: Error code: ESISP1PS_DCHP"
            }
    } else={
        :set $ISP1present false
        /system script environment remove [find where name~"ISP1"]
    }
}

# Determining ISP2 type
:if ($ISP2probeTypeStatic = 1) do={
        #ISP2 type is Static
        :do {
            :set $ISP2present true
            :set $ISP2type "STATIC"
            } on-error={
                :log error "$scriptname: Error setting ISP2 type and presentage state."
                :log error "$scriptname: Error code: ESISP2PS_STATIC"
            }
} else={
    :if ($ISP2probeTypeDynamic = 1) do={
        #ISP2 type is DHCP
        :do {
            :set $ISP2present true
            :set $ISP2type "DHCP"
            } on-error={
                :log error "$scriptname: Error setting ISP2 type and presentage state."
                :log error "$scriptname: Error code: ESISP2PS_DCHP"
            }
    } else={
        :set $ISP2present false
        /system script environment remove [find where name~"ISP2"]

    }
}

# Determining ISP3 type
:if ($ISP3probeTypeStatic = 1) do={
        #ISP3 type is Static
        :do {
            :set $ISP3present true
            :set $ISP3type "STATIC"
            } on-error={
                :log error "$scriptname: Error setting ISP3 type and presentage state."
                :log error "$scriptname: Error code: ESISP3PS_STATIC"
            }
} else={
    :if ($ISP3probeTypeDynamic = 1) do={
        #ISP3 type is DHCP
        :do {
            :set $ISP3present true
            :set $ISP3type "DHCP"
            } on-error={
                :log error "$scriptname: Error setting ISP3 type and presentage state."
                :log error "$scriptname: Error code: ESISP3PS_DCHP"
            }
    } else={
        :set $ISP3present false
        /system script environment remove [find where name~"ISP3"]
    }
}


###### ISP TYPES, PRESENSE AND DHCP/STATIC TUNNINGS ######



###### HEALTH CHECKS, ROUTING TABLES, ROUTING RULES ########

#
# Set and Deploy HealthCheck GW for ISP1 in case when ISP1 type is present
#
:if ($ISP1present) do={
    # Adding + 1 to ISPsCounter
    :set $ISPsCounter ($ISPsCounter + 1)

    # Getting current ISP1_HC1_RT for comparison and if there is no HC_RT deploy one
    :do {
        :local ISP1currentHCGW [/ip route get value-name=gateway [find where comment~"ISP1_HC1_RT"]]
        } on-error={
            :set $ISP1currentHCGW "169.254.0.1"
            /ip route add check-gateway=ping comment="ISP1_HC1_RT | Managed by ros-wht" distance=1 dst-address=$HCaddr1 gateway=$ISP1currentHCGW routing-mark=isp1_hc_rt
            }
    
    # Getting current ISP1_HC2_RT for comparison and if there is no HC_RT deploy one
    :do {
        :local ISP1currentHCGW [/ip route get value-name=gateway [find where comment~"ISP1_HC2_RT"]]
        } on-error={
            :set $ISP1currentHCGW "169.254.0.1"
            /ip route add check-gateway=ping comment="ISP1_HC2_RT | Managed by ros-wht" distance=1 dst-address=$HCaddr2 gateway=$ISP1currentHCGW routing-mark=isp1_hc_rt
            }
    
    # Getting current ISP1_HC3_RT for comparison and if there is no HC_RT deploy one
    :do {
        :local ISP1currentHCGW [/ip route get value-name=gateway [find where comment~"ISP1_HC3_RT"]]
        } on-error={
            :set $ISP1currentHCGW "169.254.0.1"
            /ip route add check-gateway=ping comment="ISP1_HC3_RT | Managed by ros-wht" distance=1 dst-address=$HCaddr3 gateway=$ISP1currentHCGW routing-mark=isp1_hc_rt
            }

### Section for getting and comparing HC route rules ###
    # Getting current ISP1_HC1_RR for comparison and if there is no HC_RR deploy one
    :do {
        :local ISP1currentHC1RR [/ip route rule get value-name=dst-address [find where comment~"ISP1_HC1_RR"]]
        :if ($ISP1currentHC1RR != $HCaddr1) do={
            /ip route rule set dst-address=$HCaddr1
        }
        } on-error={
            /ip route rule add action=lookup-only-in-table comment="ISP1_HC1_RR | Managed by ros-wht" dst-address=$HCaddr1 routing-mark=isp1_hc_rt table=isp1_hc_rt
        }

    # Getting current ISP1_HC2_RR for comparison and if there is no HC_RR deploy one
    :do {
        :local ISP1currentHC2RR [/ip route rule get value-name=dst-address [find where comment~"ISP1_HC2_RR"]]
        :if ($ISP1currentHC2RR != $HCaddr2) do={
            /ip route rule set dst-address=$HCaddr2
        }
        } on-error={
            /ip route rule add action=lookup-only-in-table comment="ISP1_HC2_RR | Managed by ros-wht" dst-address=$HCaddr2 routing-mark=isp1_hc_rt table=isp1_hc_rt
        }

    # Getting current ISP1_HC3_RR for comparison and if there is no HC_RR deploy one
    :do {
        :local ISP1currentHC3RR [/ip route rule get value-name=dst-address [find where comment~"ISP1_HC3_RR"]]
        :if ($ISP1currentHC3RR != $HCaddr3) do={
            /ip route rule set dst-address=$HCaddr3
        }
        } on-error={
            /ip route rule add action=lookup-only-in-table comment="ISP1_HC3_RR | Managed by ros-wht" dst-address=$HCaddr3 routing-mark=isp1_hc_rt table=isp1_hc_rt
        }
### Section for getting and comparing HC route rules ###

    # ISP1 is static
        :if ($ISP1type = "STATIC") do={
                # Getting current ISP1_DGW_RT for comparison
                :local ISP1staticGW [/ip route get value-name=gateway [find where comment~"ISP1_DGW_RT"]]

                # Alligning DGW route distance for ISP1 if needed
                /ip route set distance=10 comment="ISP1_DGW_RT | Managed by ros-wht" [find where comment~"ISP1_DGW_RT" && distance!=10]
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname: ISP1_DGW_RT aligned."
                    }

                # Realising compare logic for HC_GW and STATIC.
                :if ($ISP1currentHCGW != $ISP1staticGW) do={
                    # Situation when current HC GW is different with new one
                    # Seting the ISP1_HC with getted ISP1staticGW
                    /ip route set gateway=$ISP1staticGW [find where routing-mark=isp1_hc_rt && gateway!=$ISP1staticGW]
                    :if ($DebugIsOn) do={
                        :log warning ""
                        :log warning "$scriptname: Current ISP1_HC_GW is not the same with current ISP1_DGW_RT"
                        :log warning "$scriptname: Refreshing GW for ISP1_HC_RT..."
                        }
                        } else={
                            :if ($ISP1currentHCGW = $ISP1staticGW) do={
                                # Situation when current HC GW is the SAME with new
                                :if ($DebugIsOn) do={
                                    :log warning ""
                                    :log warning "$scriptname: Current ISP1_HC_GW is the same with current ISP1staticGW"
                                    :log warning "$scriptname: Nothing need to be done..."
                                    }
                                    }
                                    }

        } else={
            :if ($ISP1type = "DHCP") do={
                # Getting current ISP1dhcpGW for comparison
                :global ISP1dhcpGW
                # If there is no ISP1dhcpGW, initialize DHCP-script adding
                :if ($ISP1dhcpGW = nothing) do={
                    /ip dhcp-client set script=":if (\$bound=1) do={:global ISP1dhcpGW \"\$\"gateway-address\"\"}" default-route-distance=10 comment="ISP1 DHCP Client | Managed by ros-wht" [find where comment="ISP1"] 
                    /ip dhcp-client set disabled=yes [find where comment~"ISP1"]
                    /ip dhcp-client set disabled=no [find where comment~"ISP1"]
                    :delay 5
                }

                # Realising compare logic for DHCP.
                :if ($ISP1currentHCGW != $ISP1dhcpGW) do={
                    # Situation when current HC GW is different with new
                    # Seting the ISP1_HC with getted ISP1dhcpGW
                    /ip route set gateway=$ISP1dhcpGW [find where routing-mark=isp1_hc_rt && gateway!=ISP1staticGW]
                    :if ($DebugIsOn) do={
                        :log warning ""
                        :log warning "$scriptname: Current ISP1_HC_GW is not the same with current ISP1dhcpGW"
                        :log warning "$scriptname: Refreshing GW for ISP1_HC_RT..."
                        }
                        } else={
                            :if ($ISP1currentHCGW = $ISP1dhcpGW) do={
                                # Situation when current HC GW is the SAME with new
                                :if ($DebugIsOn) do={
                                    :log warning ""
                                    :log warning "$scriptname: Current ISP1_HC_GW is the same with current ISP1dhcpGW"
                                    :log warning "$scriptname: Nothing need to be done..."
                                    }
                                    }
                                    }
                                    } else={
                                        :log error ""
                                        :log error "$scriptname: Error ISP1 probably have unknown type!"
                                        :log error "$scriptname: Error code GWIPFHC_isp1_nonSTATIC_nonDHCP"
                                        }
                                        }

        } else={
            # there is no ISP1
             :if ($DebugIsOn) do={
                                    :log warning ""
                                    :log warning "$scriptname: Its kinda strange but.. There is no ISP1"
                                    :log warning "$scriptname: I_I "
                                    }
        }
#
##
#



#
# Set and Deploy HealthCheck GW for ISP2 in case when ISP2 type is present
#
:if ($ISP2present) do={
    # Adding + 1 to ISPsCounter
    :set $ISPsCounter ($ISPsCounter + 1)

    # Getting current ISP2_HC1_RT for comparison and if there is no HC_RT deploy one
    :do {
        :local ISP2currentHCGW [/ip route get value-name=gateway [find where comment~"ISP2_HC1_RT"]]
        } on-error={
            :set $ISP2currentHCGW "169.254.0.1"
            /ip route add check-gateway=ping comment="ISP2_HC1_RT | Managed by ros-wht" distance=1 dst-address=$HCaddr1 gateway=$ISP2currentHCGW routing-mark=isp2_hc_rt
            }
    
    # Getting current ISP2_HC2_RT for comparison and if there is no HC_RT deploy one
    :do {
        :local ISP2currentHCGW [/ip route get value-name=gateway [find where comment~"ISP2_HC2_RT"]]
        } on-error={
            :set $ISP2currentHCGW "169.254.0.1"
            /ip route add check-gateway=ping comment="ISP2_HC2_RT | Managed by ros-wht" distance=1 dst-address=$HCaddr2 gateway=$ISP2currentHCGW routing-mark=isp2_hc_rt
            }
    
    # Getting current ISP2_HC3_RT for comparison and if there is no HC_RT deploy one
    :do {
        :local ISP2currentHCGW [/ip route get value-name=gateway [find where comment~"ISP2_HC3_RT"]]
        } on-error={
            :set $ISP2currentHCGW "169.254.0.1"
            /ip route add check-gateway=ping comment="ISP2_HC3_RT | Managed by ros-wht" distance=1 dst-address=$HCaddr3 gateway=$ISP2currentHCGW routing-mark=isp2_hc_rt
            }

### Section for getting and comparing HC route rules ###
    # Getting current ISP2_HC1_RR for comparison and if there is no HC_RR deploy one
    :do {
        :local ISP2currentHC1RR [/ip route rule get value-name=dst-address [find where comment~"ISP2_HC1_RR"]]
        :if ($ISP2currentHC1RR != $HCaddr1) do={
            /ip route rule set dst-address=$HCaddr1
        }
        } on-error={
            /ip route rule add action=lookup-only-in-table comment="ISP2_HC1_RR | Managed by ros-wht" dst-address=$HCaddr1 routing-mark=isp2_hc_rt table=isp2_hc_rt
        }

    # Getting current ISP2_HC2_RR for comparison and if there is no HC_RR deploy one
    :do {
        :local ISP2currentHC2RR [/ip route rule get value-name=dst-address [find where comment~"ISP2_HC2_RR"]]
        :if ($ISP2currentHC2RR != $HCaddr2) do={
            /ip route rule set dst-address=$HCaddr2
        }
        } on-error={
            /ip route rule add action=lookup-only-in-table comment="ISP2_HC2_RR | Managed by ros-wht" dst-address=$HCaddr2 routing-mark=isp2_hc_rt table=isp2_hc_rt
        }

    # Getting current ISP2_HC3_RR for comparison and if there is no HC_RR deploy one
    :do {
        :local ISP2currentHC3RR [/ip route rule get value-name=dst-address [find where comment~"ISP2_HC3_RR"]]
        :if ($ISP2currentHC3RR != $HCaddr3) do={
            /ip route rule set dst-address=$HCaddr3
        }
        } on-error={
            /ip route rule add action=lookup-only-in-table comment="ISP2_HC3_RR | Managed by ros-wht" dst-address=$HCaddr3 routing-mark=isp2_hc_rt table=isp2_hc_rt
        }
### Section for getting and comparing HC route rules ###

    # ISP2 is static
        :if ($ISP2type = "STATIC") do={
                # Getting current ISP2_DGW_RT for comparison
                :local ISP2staticGW [/ip route get value-name=gateway [find where comment~"ISP2_DGW_RT"]]

                # Alligning DGW route distance for ISP2 if needed
                /ip route set distance=10 comment="ISP2_DGW_RT | Managed by ros-wht" [find where comment~"ISP2_DGW_RT" && distance!=10]
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname: ISP2_DGW_RT aligned."
                    }

                # Realising compare logic for HC_GW and STATIC.
                :if ($ISP2currentHCGW != $ISP2staticGW) do={
                    # Situation when current HC GW is different with new one
                    # Seting the ISP2_HC with getted ISP2staticGW
                    /ip route set gateway=$ISP2staticGW [find where routing-mark=isp2_hc_rt && gateway!=$ISP2staticGW]
                    :if ($DebugIsOn) do={
                        :log warning ""
                        :log warning "$scriptname: Current ISP2_HC_GW is not the same with current ISP2_DGW_RT"
                        :log warning "$scriptname: Refreshing GW for ISP2_HC_RT..."
                        }
                        } else={
                            :if ($ISP2currentHCGW = $ISP2staticGW) do={
                                # Situation when current HC GW is the SAME with new
                                :if ($DebugIsOn) do={
                                    :log warning ""
                                    :log warning "$scriptname: Current ISP2_HC_GW is the same with current ISP2staticGW"
                                    :log warning "$scriptname: Nothing need to be done..."
                                    }
                                    }
                                    }

        } else={
            :if ($ISP2type = "DHCP") do={
                # Getting current ISP2dhcpGW for comparison
                :global ISP2dhcpGW
                # If there is no ISP2dhcpGW, initialize DHCP-script adding
                :if ($ISP2dhcpGW = nothing) do={
                    /ip dhcp-client set script=":if (\$bound=1) do={:global ISP2dhcpGW \"\$\"gateway-address\"\"}" default-route-distance=10 comment="ISP2 DHCP Client | Managed by ros-wht" [find where comment="ISP2"] 
                    /ip dhcp-client set disabled=yes [find where comment~"ISP2"]
                    /ip dhcp-client set disabled=no [find where comment~"ISP2"]
                    :delay 5
                }

                # Realising compare logic for DHCP.
                :if ($ISP2currentHCGW != $ISP2dhcpGW) do={
                    # Situation when current HC GW is different with new
                    # Seting the ISP2_HC with getted ISP2dhcpGW
                    /ip route set gateway=$ISP2dhcpGW [find where routing-mark=isp2_hc_rt && gateway!=ISP2staticGW]
                    :if ($DebugIsOn) do={
                        :log warning ""
                        :log warning "$scriptname: Current ISP2_HC_GW is not the same with current ISP2dhcpGW"
                        :log warning "$scriptname: Refreshing GW for ISP2_HC_RT..."
                        }
                        } else={
                            :if ($ISP2currentHCGW = $ISP2dhcpGW) do={
                                # Situation when current HC GW is the SAME with new
                                :if ($DebugIsOn) do={
                                    :log warning ""
                                    :log warning "$scriptname: Current ISP2_HC_GW is the same with current ISP2dhcpGW"
                                    :log warning "$scriptname: Nothing need to be done..."
                                    }
                                    }
                                    }
                                    } else={
                                        :log error ""
                                        :log error "$scriptname: Error ISP2 probably have unknown type!"
                                        :log error "$scriptname: Error code GWIPFHC_isp2_nonSTATIC_nonDHCP"
                                        }
                                        }

        } else={
            # there is no ISP2
             :if ($DebugIsOn) do={
                                    :log warning ""
                                    :log warning "$scriptname: Its kinda strange but.. There is no ISP2"
                                    :log warning "$scriptname: I_I "
                                    }
        }
#
##
#



#
# Set and Deploy HealthCheck GW for ISP3 in case when ISP3 type is present
#
:if ($ISP3present) do={
    # Adding + 1 to ISPsCounter
    :set $ISPsCounter ($ISPsCounter + 1)

    # Getting current ISP3_HC1_RT for comparison and if there is no HC_RT deploy one
    :do {
        :local ISP3currentHCGW [/ip route get value-name=gateway [find where comment~"ISP3_HC1_RT"]]
        } on-error={
            :set $ISP3currentHCGW "169.254.0.1"
            /ip route add check-gateway=ping comment="ISP3_HC1_RT | Managed by ros-wht" distance=1 dst-address=$HCaddr1 gateway=$ISP3currentHCGW routing-mark=isp3_hc_rt
            }
    
    # Getting current ISP3_HC2_RT for comparison and if there is no HC_RT deploy one
    :do {
        :local ISP3currentHCGW [/ip route get value-name=gateway [find where comment~"ISP3_HC2_RT"]]
        } on-error={
            :set $ISP3currentHCGW "169.254.0.1"
            /ip route add check-gateway=ping comment="ISP3_HC2_RT | Managed by ros-wht" distance=1 dst-address=$HCaddr2 gateway=$ISP3currentHCGW routing-mark=isp3_hc_rt
            }
    
    # Getting current ISP3_HC3_RT for comparison and if there is no HC_RT deploy one
    :do {
        :local ISP3currentHCGW [/ip route get value-name=gateway [find where comment~"ISP3_HC3_RT"]]
        } on-error={
            :set $ISP3currentHCGW "169.254.0.1"
            /ip route add check-gateway=ping comment="ISP3_HC3_RT | Managed by ros-wht" distance=1 dst-address=$HCaddr3 gateway=$ISP3currentHCGW routing-mark=isp3_hc_rt
            }

### Section for getting and comparing HC route rules ###
    # Getting current ISP3_HC1_RR for comparison and if there is no HC_RR deploy one
    :do {
        :local ISP3currentHC1RR [/ip route rule get value-name=dst-address [find where comment~"ISP3_HC1_RR"]]
        :if ($ISP3currentHC1RR != $HCaddr1) do={
            /ip route rule set dst-address=$HCaddr1
        }
        } on-error={
            /ip route rule add action=lookup-only-in-table comment="ISP3_HC1_RR | Managed by ros-wht" dst-address=$HCaddr1 routing-mark=isp3_hc_rt table=isp3_hc_rt
        }

    # Getting current ISP3_HC2_RR for comparison and if there is no HC_RR deploy one
    :do {
        :local ISP3currentHC2RR [/ip route rule get value-name=dst-address [find where comment~"ISP3_HC2_RR"]]
        :if ($ISP3currentHC2RR != $HCaddr2) do={
            /ip route rule set dst-address=$HCaddr2
        }
        } on-error={
            /ip route rule add action=lookup-only-in-table comment="ISP3_HC2_RR | Managed by ros-wht" dst-address=$HCaddr2 routing-mark=isp3_hc_rt table=isp3_hc_rt
        }

    # Getting current ISP3_HC3_RR for comparison and if there is no HC_RR deploy one
    :do {
        :local ISP3currentHC3RR [/ip route rule get value-name=dst-address [find where comment~"ISP3_HC3_RR"]]
        :if ($ISP3currentHC3RR != $HCaddr3) do={
            /ip route rule set dst-address=$HCaddr3
        }
        } on-error={
            /ip route rule add action=lookup-only-in-table comment="ISP3_HC3_RR | Managed by ros-wht" dst-address=$HCaddr3 routing-mark=isp3_hc_rt table=isp3_hc_rt
        }
### Section for getting and comparing HC route rules ###

    # ISP3 is static
        :if ($ISP3type = "STATIC") do={
                # Getting current ISP3_DGW_RT for comparison
                :local ISP3staticGW [/ip route get value-name=gateway [find where comment~"ISP3_DGW_RT"]]

                # Alligning DGW route distance for ISP3 if needed
                /ip route set distance=10 comment="ISP3_DGW_RT | Managed by ros-wht" [find where comment~"ISP3_DGW_RT" && distance!=10]
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname: ISP3_DGW_RT aligned."
                    }

                # Realising compare logic for HC_GW and STATIC.
                :if ($ISP3currentHCGW != $ISP3staticGW) do={
                    # Situation when current HC GW is different with new one
                    # Seting the ISP3_HC with getted ISP3staticGW
                    /ip route set gateway=$ISP3staticGW [find where routing-mark=isp3_hc_rt && gateway!=$ISP3staticGW]
                    :if ($DebugIsOn) do={
                        :log warning ""
                        :log warning "$scriptname: Current ISP3_HC_GW is not the same with current ISP3_DGW_RT"
                        :log warning "$scriptname: Refreshing GW for ISP3_HC_RT..."
                        }
                        } else={
                            :if ($ISP3currentHCGW = $ISP3staticGW) do={
                                # Situation when current HC GW is the SAME with new
                                :if ($DebugIsOn) do={
                                    :log warning ""
                                    :log warning "$scriptname: Current ISP3_HC_GW is the same with current ISP3staticGW"
                                    :log warning "$scriptname: Nothing need to be done..."
                                    }
                                    }
                                    }

        } else={
            :if ($ISP3type = "DHCP") do={
                # Getting current ISP3dhcpGW for comparison
                :global ISP3dhcpGW
                # If there is no ISP3dhcpGW, initialize DHCP-script adding
                :if ($ISP3dhcpGW = nothing) do={
                    /ip dhcp-client set script=":if (\$bound=1) do={:global ISP3dhcpGW \"\$\"gateway-address\"\"}" default-route-distance=10 comment="ISP3 DHCP Client | Managed by ros-wht" [find where comment="ISP3"] 
                    /ip dhcp-client set disabled=yes [find where comment~"ISP3"]
                    /ip dhcp-client set disabled=no [find where comment~"ISP3"]
                    :delay 5
                }

                # Realising compare logic for DHCP.
                :if ($ISP3currentHCGW != $ISP3dhcpGW) do={
                    # Situation when current HC GW is different with new
                    # Seting the ISP3_HC with getted ISP3dhcpGW
                    /ip route set gateway=$ISP3dhcpGW [find where routing-mark=isp3_hc_rt && gateway!=ISP3staticGW]
                    :if ($DebugIsOn) do={
                        :log warning ""
                        :log warning "$scriptname: Current ISP3_HC_GW is not the same with current ISP3dhcpGW"
                        :log warning "$scriptname: Refreshing GW for ISP3_HC_RT..."
                        }
                        } else={
                            :if ($ISP3currentHCGW = $ISP3dhcpGW) do={
                                # Situation when current HC GW is the SAME with new
                                :if ($DebugIsOn) do={
                                    :log warning ""
                                    :log warning "$scriptname: Current ISP3_HC_GW is the same with current ISP3dhcpGW"
                                    :log warning "$scriptname: Nothing need to be done..."
                                    }
                                    }
                                    }
                                    } else={
                                        :log error ""
                                        :log error "$scriptname: Error ISP3 probably have unknown type!"
                                        :log error "$scriptname: Error code GWIPFHC_isp3_nonSTATIC_nonDHCP"
                                        }
                                        }

        } else={
            # there is no ISP3
             :if ($DebugIsOn) do={
                                    :log warning ""
                                    :log warning "$scriptname: Its kinda strange but.. There is no ISP3"
                                    :log warning "$scriptname: I_I "
                                    }
        }
#
##
#


###### HEALTH CHECKS, ROUTING TABLES, ROUTING RULES ########


:if (!$DebugIsOn) do={
:delay 15
# And finaly, back all of the our disabled deamons back
/system script run ros-wht_isc
} else={
    :log warning ""
    :log warning "$scriptname: Reached end of the script..."
    :log warning "$scriptname: Looks like all good :)"
    :log warning "$scriptname: Launching the next phase... ))"
    :delay 1
    /system script run ros-wht_isc
}