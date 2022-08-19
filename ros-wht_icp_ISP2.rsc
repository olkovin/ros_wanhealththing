# Router OS WANhealththing
# t.me/olekovin
#
# Part of the overall script group
# ISP Actioner part
# ros-wht_icp


#
# For the STATIC ISP type, there must be IP->ADDRESS and default route with comment ISP1 or ISP2
# For the DHCP (DYNAMIC) type, there must be IP->DHCP-CLIENT with comment ISP1 or ISP2
# For the LTE type, there must be LTE interface with comment ISP1 or ISP2
#
# Global vars 
:global ISP2present
:global ISPhpGood
:global CurrentISP
:global DebugIsOn

# Local vars
:local scriptname "ros-wht_icp_ISP2"


##### DUPLICATION HANDLER#####
:if ([/system script job print as-value count-only where script="scriptname"] <= 1) do={


###
### ISP2 actions handler
### 
:if ($ISP2present) do={
    # When we do have ISP2, let's initialize corresponding global vars
    :global ISP2hp
    :global ISP2type
    
     # Debug info
    :if ($DebugIsOn) do={
        :log warning ""
        :log warning "$scriptname:  Checking ISP2hp"
        :log warning ""
        }
        # Actions when ISP2 is not good
        :if (($ISPhpGood - $ISP2hp) > 1) do={
            # Debug info
            :if ($DebugIsOn) do={
            :log warning ""
            :log warning "$scriptname:  ISP2 is not good"
            :log warning ""
            }
            # And CurrentISP is ISP2
            :if ($CurrentISP = "ISP2") do={
                # Debug info
                    :if ($DebugIsOn) do={
                        :log warning ""
                        :log warning "$scriptname:  CurrentISP is $CurrentISP"
                        :log warning "$scriptname:  Checking and do some magic stuff..."
                        :log warning ""
                        }
                        # ISP2 is static
                        :if ($ISP2type = "STATIC") do={
                        # ISP2 not good and static
                            # Changing distance for the ISP2 default route
                            /ip route set distance=120 [find where comment~"ISP2_DGW_RT" && comment~"ros-wht" && distance=20]
                            # Remove all connectios for the faster reconnection via new isp
                            /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                            :delay 1
                            # Twice, to be sure :)
                            /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                            }

                # ISP2 is DHCP
                    :if ($ISP2type = "DHCP") do={
                        # Changing distance for the ISP2 DHCP default route
                        /ip dhcp-client set default-route-distance=120 [find where comment~"ISP2" && comment~"ros-wht" && default-route-distance=20]
                        
                        # Remove all connectios for the faster reconnection via new isp
                        /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                        :delay 1
                        # Twice, to be sure :)
                        /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                        } else={
                            #ISP2 not good and not STATIC or DHCP
                            :if ($DebugIsOn) do={
                                :log warning ""
                                :log warning "$scriptname:  ISP2 is not good"
                                :log warning "$scriptname:  Anc CurrentISP is $CurrentISP"
                                :log warning "$scriptname:  But ISP2 is not STATIC and not DHCP"
                                :log warning "$scriptname:  Can't understand wtd..."
                                :log warning ""
                            }
                        }
                        } else={
                            :if ($DebugIsOn) do={
                                :log warning ""
                                :log warning "$scriptname:  ISP2 is not good"
                                :log warning "$scriptname:  And CurrentISP is $CurrentISP"
                                :log warning "$scriptname:  So, do nothing."
                                :log warning ""
                                }
                                }
                                } else={
                                    # When ISP2 is good
                                    :if (($ISPhpGood - $ISP2hp) <= 1) do={
                                    # Debug info
                                    :if ($DebugIsOn) do={
                                        :log warning ""
                                        :log warning "$scriptname:  ISP2 is good"
                                        :log warning ""
                                    }
                                    # And CurrentISP is not ISP2
                                    :if ($CurrentISP != "ISP2") do={
                                        # Debug info
                                        :if ($DebugIsOn) do={
                                            :log warning ""
                                            :log warning "$scriptname:  CurrentISP is $CurrentISP"
                                            :log warning "$scriptname:  Checking and do some magic stuff..."
                                            :log warning ""
                                        }
                                            # Actions when ISP2 is STATIC
                                                :if ($ISP2type = "STATIC") do={
                                                    # ISP2 good and static but not current
                                                    :if ($CurrentISP != "ISP2") do={
                                                        # Changing distance for the ISP2 default route
                                                        /ip route set distance=20 [find where comment~"ISP2_DGW_RT" && comment~"ros-wht" && distance=120]
                                                        # Remove all connectios for the faster reconnection via new isp
                                                        /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                                                        :delay 1
                                                        # Twice, to be sure :)
                                                        /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                                                        # And set ISP2 as CurrentISP
                                                        :set $CurrentISP "ISP2"
                                                        } else={
                                                            :if ($DebugIsOn) do={
                                                                :log warning ""
                                                                :log warning "$scriptname:  ISP2 is good"
                                                                :log warning "$scriptname:  And CurrentISP is $CurrentISP"
                                                                :log warning "$scriptname:  So, do nothing."
                                                                :log warning ""
                                                            }
                                                            }
                                                            }
                                                :if ($ISP2type = "DHCP") do={
                                                    # ISP2 not good and DHCP
                                                    :if ($CurrentISP != "ISP2") do={
                                                        # Changing distance for the ISP2 DHCP default route
                                                        /ip dhcp-client set default-route-distance=31 [find where comment~"ISP2" && comment~"ros-wht" && default-route-distance=20]
                                                        
                                                        # Remove all connectios for the faster reconnection via new isp
                                                        /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                                                        :delay 1
                                                        # Twice, to be sure :)
                                                        /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                                                        # And set ISP2 as CurrentISP
                                                        :set $CurrentISP "ISP2"
                                                        } else={
                                                            :if ($DebugIsOn) do={
                                                                :log warning ""
                                                                :log warning "$scriptname:  ISP2 is not good"
                                                                :log warning "$scriptname:  And CurrentISP is $CurrentISP"
                                                                :log warning "$scriptname:  So, do nothing."
                                                                :log warning ""
                                                            }
                                                            }
                                                            } else={
                                                                #ISP2 not good and not STATIC or DHCP
                                                                    :if ($DebugIsOn) do={
                                                                        :log warning ""
                                                                        :log warning "$scriptname:  ISP2 is not good"
                                                                        :log warning "$scriptname:  But ISP2 is not STATIC and not DHCP"
                                                                        :log warning "$scriptname:  Can't understand wtd..."
                                                                        :log warning ""
                                                                        }
                                                                        }
                                                                        }
                                                                        }
                                                                        }
                                                                        }
###
#######
###

} else={
        :if ($DebugIsOn) do={
            :log warning ""
            :log warning "$scripname: Script is run already, so I will not run the second one."
            :log warning ""
            }
}