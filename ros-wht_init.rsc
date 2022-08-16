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
#
#
#
# ISP(X)_DGW_RT must be set on all of the ISP static routes, where (X) is the number from 1 to 3.
# e.g. ISP1_DGW_RT


# Global vars
:global ISP1present
:global ISP2present
:global ISP3present
:global ISP1type
:global ISP2type
:global ISP3type
:global DebugIsOn

# Local vars
:local scriptname "ros-wht_init"

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
    }
}


###### ISP TYPES, PRESENSE AND DHCP/STATIC TUNNINGS ######


###### HEALTH CHECKS AND ROUTING TABLES ########

#
# Set and Deploy HealthCheck GW for ISP1 in case when ISP1 type is present
#
:if ($ISP1present) do={
    # ISP1 is static
        :if ($ISP1type = "STATIC") do={
                # Getting current ISP1_HC_GW for comparison
                :do {
                    :local ISP1currentHCGW [/ip route get value-name=gateway [find where comment~"ISP1_HC_RT"]]
                    } on-error={
                        :set $ISP1currentHCGW "169.40.4.1"
                        :local ISP1hcNeedToBeDeployed true
                        }

                :local ISP1staticGW [/ip route get value-name=gateway [find where comment~"ISP1_DGW_RT"]]
                   
                    # Deploy ISP1_HC_RT if needed.
                        :if ($ISP1hcNeedToBeDeployed) do={
                            /ip route add check-gateway=ping comment="ISP1_HC_RT | ros-wht" distance=1 gateway=169.0.0.1 routing-mark=isp1_hc_rt
                            }

                # Realising compare logic for STATIC.
                :if ($ISP1currentHCGW != $ISP1staticGW) do={
                    # Situation when current HC GW is different with new one
                    # Seting the ISP1_HC with getted ISP1staticGW
                    /ip route set gateway=$ISP1staticGW [find where comment~"ISP1_HC_RT" && gateway!=$ISP1staticGW]
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
                # Getting current ISP1_HC_GW for comparison
                :local ISP1currentHCGW [/ip route get value-name=gateway [find where comment~"ISP1_HC_RT"]]
                :global ISP1dhcpGW
                # Realising compare logic for DHCP.
                :if ($ISP1currentHCGW != $ISP1dhcpGW) do={
                    # Situation when current HC GW is different with new
                    # Seting the ISP1_HC with getted ISP1dhcpGW
                    /ip route set gateway=$ISP1dhcpGW [find where comment~"ISP1_HC_RT" && gateway!=ISP1staticGW]
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

        } else ={
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
    # ISP2 is static
        :if ($ISP2type = "STATIC") do={
                # Getting current ISP2_HC_GW for comparison
                :do {
                    :local ISP2currentHCGW [/ip route get value-name=gateway [find where comment~"ISP2_HC_RT"]]
                    } on-error={
                        :set $ISP2currentHCGW "169.40.4.1"
                        :local ISP2hcNeedToBeDeployed true
                        }

                :local ISP2staticGW [/ip route get value-name=gateway [find where comment~"ISP2_DGW_RT"]]
                   
                    # Deploy ISP2_HC_RT if needed.
                        :if ($ISP2hcNeedToBeDeployed) do={
                            /ip route add check-gateway=ping comment="ISP2_HC_RT | ros-wht" distance=1 gateway=169.0.0.1 routing-mark=ISP2_hc_rt
                            }

                # Realising compare logic for STATIC.
                :if ($ISP2currentHCGW != $ISP2staticGW) do={
                    # Situation when current HC GW is different with new one
                    # Seting the ISP2_HC with getted ISP2staticGW
                    /ip route set gateway=$ISP2staticGW [find where comment~"ISP2_HC_RT" && gateway!=$ISP2staticGW]
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
                # Getting current ISP2_HC_GW for comparison
                :local ISP2currentHCGW [/ip route get value-name=gateway [find where comment~"ISP2_HC_RT"]]
                :global ISP2dhcpGW
                # Realising compare logic for DHCP.
                :if ($ISP2currentHCGW != $ISP2dhcpGW) do={
                    # Situation when current HC GW is different with new
                    # Seting the ISP2_HC with getted ISP2dhcpGW
                    /ip route set gateway=$ISP2dhcpGW [find where comment~"ISP2_HC_RT" && gateway!=ISP2staticGW]
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
                                        :log error "$scriptname: Error code GWIPFHC_ISP2_nonSTATIC_nonDHCP"
                                        }
                                        }

        } else ={
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
    # ISP3 is static
        :if ($ISP3type = "STATIC") do={
                # Getting current ISP3_HC_GW for comparison
                :do {
                    :local ISP3currentHCGW [/ip route get value-name=gateway [find where comment~"ISP3_HC_RT"]]
                    } on-error={
                        :set $ISP3currentHCGW "169.40.4.1"
                        :local ISP3hcNeedToBeDeployed true
                        }

                :local ISP3staticGW [/ip route get value-name=gateway [find where comment~"ISP3_DGW_RT"]]
                   
                    # Deploy ISP3_HC_RT if needed.
                        :if ($ISP3hcNeedToBeDeployed) do={
                            /ip route add check-gateway=ping comment="ISP3_HC_RT | ros-wht" distance=1 gateway=169.0.0.1 routing-mark=ISP3_hc_rt
                            }

                # Realising compare logic for STATIC.
                :if ($ISP3currentHCGW != $ISP3staticGW) do={
                    # Situation when current HC GW is different with new one
                    # Seting the ISP3_HC with getted ISP3staticGW
                    /ip route set gateway=$ISP3staticGW [find where comment~"ISP3_HC_RT" && gateway!=$ISP3staticGW]
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
                # Getting current ISP3_HC_GW for comparison
                :local ISP3currentHCGW [/ip route get value-name=gateway [find where comment~"ISP3_HC_RT"]]
                :global ISP3dhcpGW
                # Realising compare logic for DHCP.
                :if ($ISP3currentHCGW != $ISP3dhcpGW) do={
                    # Situation when current HC GW is different with new
                    # Seting the ISP3_HC with getted ISP3dhcpGW
                    /ip route set gateway=$ISP3dhcpGW [find where comment~"ISP3_HC_RT" && gateway!=ISP3staticGW]
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
                                        :log error "$scriptname: Error code GWIPFHC_ISP3_nonSTATIC_nonDHCP"
                                        }
                                        }

        } else ={
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

###### HEALTH CHECKS AND ROUTING TABLES ########



:delay 15
# And finaly, back all of the our disabled deamons back

/system scheduler set disabled=no [find where comment~"deamon" && comment~"init"]