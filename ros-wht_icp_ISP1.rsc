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
:global ISP1present
:global ISPhpGood
:global CurrentISP
:global DebugIsOn

# Local vars
:local scriptname "ros-wht_icp_ISP1"


##### DUPLICATION HANDLER#####
:if ([/system script job print as-value count-only where script="scriptname"] <= 1) do={

###
### ISP1 actions handler
### 
:if ($ISP1present) do={
    # When we do have ISP1, let's initialize corresponding global vars
    :global ISP1hp
    :global ISP1type
    
     # Debug info
    :if ($DebugIsOn) do={
        :log warning ""
        :log warning "$scriptname:  Checking ISP1hp"
        :log warning ""
        }
        # Actions when ISP1 is not good
        :if (($ISPhpGood - $ISP1hp) > 1) do={
            # Debug info
            :if ($DebugIsOn) do={
            :log warning ""
            :log warning "$scriptname:  ISP1 is not good"
            :log warning ""
            }
            # And CurrentISP is ISP1
            :if ($CurrentISP = "ISP1") do={
                # Debug info
                    :if ($DebugIsOn) do={
                        :log warning ""
                        :log warning "$scriptname:  CurrentISP is $CurrentISP"
                        :log warning "$scriptname:  Checking and do some magic stuff..."
                        :log warning ""
                        }
                        # ISP1 is static
                        :if ($ISP1type = "STATIC") do={
                        # ISP1 not good and static
                            # Changing distance for the ISP1 default route
                            /ip route set distance=110 [find where comment~"ISP1_DGW_RT" && comment~"ros-wht" && distance=10]
                            # Remove all connectios for the faster reconnection via new isp
                            /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                            :delay 1
                            # Twice, to be sure :)
                            /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                            }

                # ISP1 is DHCP
                    :if ($ISP1type = "DHCP") do={
                        # Changing distance for the ISP1 DHCP default route
                        /ip dhcp-client set default-route-distance=110 [find where comment~"ISP1" && comment~"ros-wht" && default-route-distance=10]
                        
                        # Remove all connectios for the faster reconnection via new isp
                        /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                        :delay 1
                        # Twice, to be sure :)
                        /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                        } else={
                            #ISP1 not good and not STATIC or DHCP
                            :if ($DebugIsOn) do={
                                :log warning ""
                                :log warning "$scriptname:  ISP1 is not good"
                                :log warning "$scriptname:  Anc CurrentISP is $CurrentISP"
                                :log warning "$scriptname:  But ISP1 is not STATIC and not DHCP"
                                :log warning "$scriptname:  Can't understand wtd..."
                                :log warning ""
                            }
                        }
                        } else={
                            :if ($DebugIsOn) do={
                                :log warning ""
                                :log warning "$scriptname:  ISP1 is not good"
                                :log warning "$scriptname:  And CurrentISP is $CurrentISP"
                                :log warning "$scriptname:  So, do nothing."
                                :log warning ""
                                }
                                }
                                } else={
                                    # When ISP1 is good
                                    :if (($ISPhpGood - $ISP1hp) <= 1) do={
                                    # Debug info
                                    :if ($DebugIsOn) do={
                                        :log warning ""
                                        :log warning "$scriptname:  ISP1 is good"
                                        :log warning ""
                                    }
                                    # And CurrentISP is not ISP1
                                    :if ($CurrentISP != "ISP1") do={
                                        # Debug info
                                        :if ($DebugIsOn) do={
                                            :log warning ""
                                            :log warning "$scriptname:  CurrentISP is $CurrentISP"
                                            :log warning "$scriptname:  Checking and do some magic stuff..."
                                            :log warning ""
                                        }
                                            # Actions when ISP1 is STATIC
                                                :if ($ISP1type = "STATIC") do={
                                                    # ISP1 good and static but not current
                                                    :if ($CurrentISP != "ISP1") do={
                                                        # Changing distance for the ISP1 default route
                                                        /ip route set distance=10 [find where comment~"ISP1_DGW_RT" && comment~"ros-wht" && distance=110]
                                                        # Remove all connectios for the faster reconnection via new isp
                                                        /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                                                        :delay 1
                                                        # Twice, to be sure :)
                                                        /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                                                        # And set ISP1 as CurrentISP
                                                        :set $CurrentISP "ISP1"
                                                        } else={
                                                            :if ($DebugIsOn) do={
                                                                :log warning ""
                                                                :log warning "$scriptname:  ISP1 is good"
                                                                :log warning "$scriptname:  And CurrentISP is $CurrentISP"
                                                                :log warning "$scriptname:  So, do nothing."
                                                                :log warning ""
                                                            }
                                                            }
                                                            }
                                                :if ($ISP1type = "DHCP") do={
                                                    # ISP1 not good and DHCP
                                                    :if ($CurrentISP != "ISP1") do={
                                                        # Changing distance for the ISP1 DHCP default route
                                                        /ip dhcp-client set default-route-distance=31 [find where comment~"ISP1" && comment~"ros-wht" && default-route-distance=10]
                                                        
                                                        # Remove all connectios for the faster reconnection via new isp
                                                        /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                                                        :delay 1
                                                        # Twice, to be sure :)
                                                        /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                                                        # And set ISP1 as CurrentISP
                                                        :set $CurrentISP "ISP1"
                                                        } else={
                                                            :if ($DebugIsOn) do={
                                                                :log warning ""
                                                                :log warning "$scriptname:  ISP1 is not good"
                                                                :log warning "$scriptname:  And CurrentISP is $CurrentISP"
                                                                :log warning "$scriptname:  So, do nothing."
                                                                :log warning ""
                                                            }
                                                            }
                                                            } else={
                                                                #ISP1 not good and not STATIC or DHCP
                                                                    :if ($DebugIsOn) do={
                                                                        :log warning ""
                                                                        :log warning "$scriptname:  ISP1 is not good"
                                                                        :log warning "$scriptname:  But ISP1 is not STATIC and not DHCP"
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