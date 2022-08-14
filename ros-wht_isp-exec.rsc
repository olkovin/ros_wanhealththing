# Router OS WANhealththing
# t.me/olekovin
#
# Part of the overall script group
# Client ISP Actioner part
#
#
# For the STATIC ISP type, there must be IP->ADDRESS and default route with comment ISP1 or ISP2
# For the DHCP (DYNAMIC) type, there must be IP->DHCP-CLIENT with comment ISP1 or ISP2
# For the LTE type, there must be LTE interface with comment ISP1 or ISP2
#
# Global vars 
:global cliISP2present
:global cliISP1type
:global cliISP2type
:global cliISP1state
:global cliISP2state
:global cliCurrentISP
:global DebugIsOn

##### DUPLICATION HANDLER#####
:if ([/system script job print as-value count-only where script="rwsv-cist"] <= 1) do={
        #  Check CLI ISP1 status
        :if ($cliISP1state = "up") do={
            # Check current CLI ISP
            :if ($cliCurrentISP = "ISP1") do={
                    :if ($DebugIsOn) do={
                        :log warning ""
                        :log warning "rwsv-cist.rsc"
                        :log warning "ISP1 still current ISP, and nothing would be changed"
                    } else={}
            } else={
                ### !true -> 
                # 1) change to ISP1
                # 2) change vars
                # 3) togle vpn cli
                #### Apply routing actions depending on ISP1 IP address type
                :if ($cliISP1type = "STATIC") do={
                    #ISP1 STATIC
                    :do {
                        # Enable and re-set params for the ISP1 default route
                        /ip route set disabled=no distance=10 [find where comment~"ISP1_GW_RT" && distance!=10]
                        # Isolated ISP2 operations
                        :if ($cliISP2present) do={
                            :delay 1
                            # Temporary disable ISP2 interface, so all connections will go trough ISP1
                            /interface set disabled=yes [find where comment="ISP2" && disabled!=yes]
                            # For more confidence, clear all connections in conn-track also 
                            /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                            # Wait 15s
                            :delay 15
                            # Enable ISP2 interface again, so that we can reconnect to it in the future, when ISP1 goes down
                            /interface set disabled=no [find where comment="ISP2" && disabled!=no]
                            :delay 15
                        } else={
                            #Isolation for the ISP2 actions, for the cases when there is no ISP2
                        }
                    } on-error={
                        # Some excpetion handling
                        :log error ""
                        :log error "Error when changing default route distance for ISP1"
                        :log error "Error code: EWCDRD_ISP1_STATIC"
                    }
                    # After ISP changing operations togle the SSTP-CLIENT to reconnect
                    :do {
                        /system script run rwsv-vpncli-tglr
                    } on-error={
                        # Some exception handling
                            :log error ""
                            :log error "Error when calling SSTP toggler."
                            :log error "Error code: EWCSSTPT_ISP1_STATIC"
                    }
                    # Set the current cliISP
                    :do {:set $cliCurrentISP "ISP1"} on-error={
                        :log error ""
                        :log error "Error when setting CLIcurrentISP to ISP1"
                        :log error "Error code: EWSC_ISP1_static"
                    }
                } else={
                    :if ($cliISP1type = "DHCP") do={
                        #ISP1 DHCP
                        :do {
                            /ip dhcp-client set default-route-distance=10 disabled=no [find where comment="ISP1" && default-route-distance!=10]
                            :if ($cliISP2present) do={
                                :delay 1
                                # Temporary disable ISP2 interface, so all connections will go trough ISP1
                                /interface set disabled=yes [find where comment="ISP2"]
                                # For more confidence, clear all connections in conn-track also 
                                /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                                # Wait 15s
                                :delay 15
                                # Enable ISP2 interface again, so that we can reconnect to it in the future, when ISP1 goes down
                                /interface set disabled=no [find where comment="ISP2"]
                                :delay 15
                            } else={
                            #Isolation for the ISP2 actions, for the cases when there is no ISP2
                            }
                            } on-error={
                            :log error ""
                            :log error "Error when changing default route distance for ISP1"
                            :log error "Error code: EWCDRD_ISP1_DHCP"
                        }
                        :do {
                            /system script run rwsv-vpncli-tglr
                        } on-error={
                            :log error ""
                            :log error "Error when calling SSTP toggler."
                            :log error "Error code: EWCSSTPT_ISP1_DHCP"
                        }
                        :do {:set $cliCurrentISP "ISP1"} on-error={
                            :log error ""
                            :log error "Error when setting CLIcurrentISP to ISP1"
                            :log error "Error code: EWSC_ISP1_DHCP"
                        }
                        } else={
                        :if ($cliISP1type = "LTE") do={
                            #ISP1 LTE
                            :do {
                                ## IF LTE PERSIST IN A SYSTEM, UNCOMMENT NEXT LINE!!!!!
                                #/interface lte apn set default-route-distance=10 [find where name="ISP1"]
                                :if ($cliISP2present) do={
                                    :delay 1
                                    # Temporary disable ISP2 interface, so all connections will go trough ISP1
                                    /interface set disabled=yes [find where comment="ISP2"]
                                    # For more confidence, clear all connections in conn-track also 
                                    /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                                    # Wait 15s
                                    :delay 15
                                    # Enable ISP2 interface again, so that we can reconnect to it in the future, when ISP1 goes down
                                    /interface set disabled=no [find where comment="ISP2"]
                                    :delay 15
                                } else={
                                    #Isolation for the ISP2 actions, for the cases when there is no ISP2
                                }
                            } on-error={
                                    :log error ""
                                    :log error "Error when changing default route distance for ISP1"
                                    :log error "Error code: EWCDRD_ISP1_LTE"
                            }
                                :do {
                                    /system script run rwsv-vpncli-tglr
                            } on-error={
                                :log error ""
                                :log error "Error when calling SSTP toggler."
                                :log error "Error code: EWCSSTPT_ISP1_LTE"
                            }
                            :do {:set $cliCurrentISP "ISP1"} on-error={
                                :log error ""
                                :log error "Error when setting cliCurrentISP to ISP1"
                                :log error "Error code: EWSC_ISP1_LTE"
                            }
                        } else={
                            #ISP1 is not dynamic or static or LTE
                            :log error ""
                            :log error "Current ISP is not ISP1, ISP1 is online, but I can't determine the ISP1 type to switch."
                            :log error ""
                        }
                    }
                }
            }       
        } else={
            :if ($cliISP1state = "down") do={
                # Check if there ISP2 presents
                :if ($cliISP2present) do={
                    ## Get CLI ISP2 status
                    #################################### Decrease PRIO for ISP1 #######################################
                    :if ($cliISP1type = "STATIC") do={
                        :do {
                             /ip route set disabled=no distance=21 [find where comment~"ISP1_GW_RT" && distance!=21]
                        } on-error={
                            :log error ""
                            :log error "Error when decreasing ISP1 prio."
                            :log error "Error code: EWDISP1P_static"
                        }
                    } else={
                        :if ($cliISP1type = "DHCP") do={
                            :do {
                                /ip dhcp-client set default-route-distance=21 disabled=no [find where comment="ISP1" && default-route-distance!=21]
                            } on-error={
                                :log error ""
                                :log error "Error when decreasing ISP1 prio."
                                :log error "Error code: EWDISP1P_dhcp"
                            }
                        } else={
                            :if ($cliISP1type = "LTE") do={
                                ## IF LTE PERSIST IN A SYSTEM, UNCOMMENT NEXT LINE!!!!!
                                #/interface lte apn set default-route-distance=21 [find where name="ISP1"]
                            } else={
                                    :log error ""
                                    :log error "Current ISP is not ISP1, ISP1 is down, but I can't determine the ISP1 type to change routing priorities"
                                    :log error "ERROR CODE: DPRIOFISP1_fatal-error"
                            }
                        }
                    }
                    :if ($cliISP2state = "up") do={
                        :if ($cliCurrentISP != "ISP2") do={
                        ### up -> change to ISP2, change vars, togle sstp
                         #### Apply routing actions depending on ISP1 IP address type
                        :if ($cliISP2type = "STATIC") do={
                            #ISP2 STATIC
                            :do {
                                /ip route set disabled=no distance=20 [find where comment~"ISP2_GW_RT" && distance!=20]
                                :delay 1
                                # Temporary disable ISP1 interface, so all connections will go trough ISP2
                                /interface set disabled=yes [find where comment="ISP1"]
                                # For more confidence, clear all connections in conn-track also 
                                /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                                # Wait 15s
                                :delay 15
                                # Enable ISP1 interface again, so that we can reconnect to it in the future, when ISP1 goes down
                                /interface set disabled=no [find where comment="ISP1"]
                                :delay 15
                                } on-error={
                                    :log error ""
                                    :log error "Error when changing default route distance for ISP2"
                                    :log error "Error code: EWCDRD_ISP2_STATIC"
                                }
                            :do {
                               /system script run rwsv-vpncli-tglr
                            } on-error={
                                :log error ""
                                :log error "Error when calling SSTP toggler."
                                :log error "Error code: EWCSSTPT_ISP2_static"
                            }
                            :do {:set $cliCurrentISP "ISP2"} on-error={
                                :log error ""
                                :log error "Error when setting CLIcurrentISP to ISP2"
                                :log error "Error code: EWSC_ISP2_static"
                            }
                        } else={
                            :if ($cliISP2type = "DHCP") do={
                                #ISP2 DHCP
                                :do {
                                    /ip dhcp-client set default-route-distance=20 disabled=no [find where comment="ISP2" && default-route-distance!=20]
                                    :delay 1
                                    # Temporary disable ISP2 interface, so all connections will go trough ISP1
                                    /interface set disabled=yes [find where comment="ISP1"]
                                    # For more confidence, clear all connections in conn-track also 
                                    /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                                    # Wait 15s
                                    :delay 15
                                    # Enable ISP1 interface again, so that we can reconnect to it in the future, when ISP1 goes down
                                    /interface set disabled=no [find where comment="ISP1"]
                                    :delay 15
                                } on-error={
                                    :log error ""
                                    :log error "Error when changing default route distance for ISP2"
                                    :log error "Error code: EWCDRD_ISP2_DHCP"
                                }

                                :do {
                                    /system script run rwsv-vpncli-tglr
                                } on-error={
                                    :log error ""
                                    :log error "Error when calling SSTP toggler."
                                    :log error "Error code: EWCSSTPT_ISP2_DHCP"
                                }                                

                                :do {:set $cliCurrentISP "ISP2"} on-error={
                                    :log error ""
                                    :log error "Error when setting CLIcurrentISP to ISP2"
                                    :log error "Error code: EWSC_ISP2_static"
                                }
                            } else={
                                    :if ($cliISP2type = "LTE") do={
                                    #ISP2 LTE
                                            :do {
                                            ## IF LTE ISP2 PERSIST IN A SYSTEM, UNCOMMENT NEXT LINE!!!!!
                                            #/interface lte apn set default-route-distance=20 [find where name="ISP2"]
                                            :delay 1
                                            # Temporary disable ISP1 interface, so all connections will go trough ISP2
                                            /interface set disabled=yes [find where comment="ISP1"]
                                            # For more confidence, clear all connections in conn-track also 
                                            /ip firewall connection remove [find where src-address!=127.0.0.1:0]
                                            # Wait 15s
                                            :delay 15
                                            # Enable ISP2 interface again, so that we can reconnect to it in the future, when ISP1 goes down
                                            /interface set disabled=no [find where comment="ISP1"]
                                            :delay 15
                            } on-error={
                                    :log error ""
                                    :log error "Error when changing default route distance for ISP2"
                                    :log error "Error code: EWCDRD_ISP2_LTE"
                            }
                                :do {
                                    /system script run rwsv-vpncli-tglr
                            } on-error={
                                :log error ""
                                :log error "Error when calling SSTP toggler."
                                :log error "Error code: EWCSSTPT_ISP2_LTE"
                            }
                            :do {:set $cliCurrentISP "ISP2"} on-error={
                                :log error ""
                                :log error "Error when setting cliCurrentISP to ISP2"
                                :log error "Error code: EWSC_ISP2_LTE"
                            }
                        } else={
                            #ISP2 is not dynamic or static or LTE
                            :log error ""
                            :log error "Current ISP is not ISP2, ISP2 is online, but I can't determine the ISP2 type to switch."
                            :log error ""
                        }
                            }
                }
                        } else={
                            :if ($DebugIsOn) do={
                                # Situation when ISP1 down, ISP2 up, and ISP2 is the current ISP
                                :log warning ""
                                :log warning "rwsv-cist.rsc"
                                :log warning "ISP2 still current ISP, and nothing would be changed"
                            } else={}
                        }
                    } else={
                        :if ($cliISP2state = "down") do={
                            :if ($DebugIsOn) do={
                                :log warning ""
                                :log warning "rwsv-cist.rsc"
                                :log warning "Current ISP is not ISP1, ISP1 is down."
                                :log warning "ISP2 is also down, so what I suppouse to do?"
                                :log warning "JUST F***G WAIT :)"
                            }
                        } else={
                            # Some exception on cliISP2state checker
                            # cliISP2state is not up or down, but present in the config
                                :set $cliCurrentISP ""
                                :log error ""
                                :log error "Error! cliISP2state got anomaly"
                                :log error "State is not up or down, but ISP2 present in the config"
                                :log error "Current client ISP was cleaned!!!"
                                :log error "Error code: CLIISP2STATECHECKER_fatal"
                        }
                    }
                } else={
                    :log info "ISP1 is down, but there is no backup ISP2."
                    :log info "So nothing can be done..."
                }
            } else={
                # Some exception on cliISP1state checker
                # cliISP1state is not up or down

                # Get system uptime for declaring some functions
                :local SysUptime [/system resource get uptime]

                # Suppressing the error message if system just started up
                :if ($SysUptime < 1m) do={
                    :if ($DebugIsOn) do={
                    :log warning "SystemUptime is less than 1m"
                    :log warning "Errors suppressed."
                    } else={
                        :set $cliCurrentISP ""
                        :log error ""
                        :log error "Error! cliISP1state got anomaly"
                        :log error "State is not up or down"
                        :log error "Current client ISP was cleaned!!!"
                        :log error "Error code: CLIISP1STATECHECKER_fatal"
                        }
                    }
                }
    } 
} else={
    :if ($DebugIsOn) do={
        :log warning ""
        :log warning "rwsv-cist.rsc"
        :log warning "CIST script is run already, so I will not run the second one."
        :log warning ""
    } else={}
}