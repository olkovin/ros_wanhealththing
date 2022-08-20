# Router OS WANhealththing
# t.me/olekovin
# github.com/olkovin/ros_wanhealththing
# Part of the overall script group
# Device ISP state determinator part
# ros-wht_isc

# Global vars
:global ISP1present
:global ISP2present
:global ISP3present

# Local vars
:local scriptname "ros-wht_isc"

# You can change it to whatever host you want to use as healthcheck in the iit script
# If there is default, 1.1.1.1, 9.9.9.9 and 8.8.8.8 will be used in healthcheck 
:global HCaddr1
:global HCaddr2
:global HCaddr3

# You can change ping interval and pings count to whatever you need
# Default values is 0.5s for ping interval and 4 for the pingscount
# Hint: lowering interval is more suitable for more stable connections
# Hint: 
:global pingsinterval
:global pingscount
:global rosWHTrunningInterval
:global rosWHTiscDeamonPaused
:global DebugIsOn


# Duplication run handler
# Check if checker is already running now, dont do anything.
:if ([/system script job print as-value count-only where script=$scripname] <= 1) do={
    # Check if there is no Pause reqest from ICP
        # But before check if rosWHTiscDeamonPaused, isn't !bool
        :local typeofrosWHTiscDeamonPaused [:typeof [$rosWHTiscDeamonPaused]]
        :if ($typeofrosWHTiscDeamonPaused != "bool" ) do={
            :set $rosWHTiscDeamonPaused false
        }
            :if (!$rosWHTiscDeamonPaused) do={
                # Fixining the script owner
                :local currentScriptOwner [/system script get value-name=owner [find where name~"$scriptname"]]
                :local correctOwner "ros-wht"

                :if ($currentScriptOwner != $correctOwner) do={
                    /system script set owner=$correctOwner [find where name~"$scriptname"]
                    
                    :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname:  Script owner is not ros-wht"
                    :log warning "$scriptname:  Changing..."
                    :log warning ""
                }
                }

                # Fixing the script running time
                    :global rosWHTScriptRunStartUptimeStamp [/system resource get value-name=uptime]
                    
                    :if ($DebugIsOn) do={
                                :log warning ""
                                :log warning "$scriptname:  rosWHTScriptRunStartUptimeStamp is $rosWHTScriptRunStartUptimeStamp"
                                :log warning ""
                    }

                # Displaying debug info, if DebuIsOn True
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname:  STARTED"
                    :log warning ""
                }

            # Calculating max health per ISP
            :global ISPhpGood
            :local ISPhpGoodCalculated ($pingscount * 3)
            :if ($ISPhpGood!= $ISPhpGoodCalculated) do={
                :set $ISPhpGood ($ISPhpGoodCalculated)

                    # Displaying debug info, if DebuIsOn True
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname: ISPhpGood is $ISPhpGood"
                    :log warning "$scriptname: ISPhpGoodCalculated is $ISPhpGoodCalculated"
                    :log warning "$scriptname: Aligned ISPhpGood"
                    :log warning ""
                }
            }

            # Incorrect type of vars fix
            :local typeofpingscount [:typeof $pingscount]

                    # Displaying debug info, if DebuIsOn True
                    :if ($DebugIsOn) do={
                        :log warning ""
                        :log warning "$scriptname:  typeofpingscount type succesfully get"
                        :log warning "$scriptname: typeofpingscount is $typeofpingscount"
                        :log warning ""
                    }

            :if ($typeofpingscount != "num") do={
                    /system script environment remove [find where name=pingscount]
                    :global pingscount 2
                    :local typeofpingscount [:typeof $pingscount]
                    :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname: Error, when tring to use pingscount"
                    :log warning "$scriptname: Perhaps pingscount was set from environment manualy."
                    :log warning "$scriptname: Will use the default values - $pingscount"
                    :log warning "$scriptname: typeofpingscount is $typeofpingscount"
                    :log warning ""
                    }
            }

            :local typeofpingsinterval [:typeof $pingsinterval]

                    # Displaying debug info, if DebuIsOn True
                    :if ($DebugIsOn) do={
                        :log warning ""
                        :log warning "$scriptname:  typeofpingsinterval type succesfully get"
                        :log warning "$scriptname: typeofpingsinterval is $typeofpingsinterval"
                        :log warning ""
                    }

            :if ($typeofpingsinterval != "num") do={
                    /system script environment remove [find where name=pingsinterval]
                    :global pingsinterval 1
                    :local typeofpingsinterval [:typeof $pingsinterval]

                    :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname: Error, when tring to use pingsinterval"
                    :log warning "$scriptname: Perhaps pingsinterval was set from environment manualy."
                    :log warning "$scriptname: Will use the default values - $pingsinterval"
                    :log warning "$scriptname: typeofpingsinterval is $typeofpingsinterval"
                    :log warning ""
                    }
            }

            ### Passing state of the providers getted from netwatch to global vars
                # Passing state of the ISP1
                :if ($ISP1present) do={
                
                # Initializing global var for ISP1 healhpoints
                :global ISP1hpLatest
                :global ISP1hpPrevious

                # Debug info 
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname:  Checking health of the ISP1"
                    :log warning ""
                }

                # Local vars
                :local ISP1partialstate1
                :local ISP1partialstate2
                :local ISP1partialstate3

                # Checking if the healthchecks are reachable only from specific RT, checking HC and setting the ISPstate
        
                :set $ISP1partialstate1 [/ping $HCaddr1 interval=$pingsinterval count=$pingscount routing-table=isp1_hc_rt]
                :set $ISP1partialstate2 [/ping $HCaddr2 interval=$pingsinterval count=$pingscount routing-table=isp1_hc_rt]
                :set $ISP1partialstate3 [/ping $HCaddr3 interval=$pingsinterval count=$pingscount routing-table=isp1_hc_rt]

                :set $ISP1hpPrevious ($ISP1hpLatest)
                :set $ISP1hpLatest ($ISP1partialstate1 + $ISP1partialstate2 + $ISP1partialstate3)

                :if ($DebugIsOn) do={
                    :local ISP1hpLatestVarType [:typeof $ISP1hpLatest;]
                    :log warning ""
                    :log warning "$scriptname:  ISP1 healhpoint is $ISP1hpLatest"
                    :log warning "ISP1hpLatest vartype is $ISP1hpLatestVarType"
                    :log warning ""
                }

                } else={
                        # Displaying debug info, if DebuIsOn True
                        :if ($DebugIsOn) do={
                            :log warning ""
                            :log warning "$scriptname:  There is no ISP1 configured. Skipping and setting the ISP1hpLatest to 0."
                            :log warning ""
                        }
                        :set $ISP1hpLatest 0
                }

                # Passing state of the ISP2
                :if ($ISP2present) do={

                # Initializing global var for ISP2 healhpoints
                :global ISP2hpLatest
                :global ISP2hpPrevious

                # Debug info 
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname:  Checking health of the ISP2"
                    :log warning ""
                }

                # Local vars
                :local ISP2partialstate1
                :local ISP2partialstate2
                :local ISP2partialstate3

                # Checking the healthchecks and setting the ISPstate
                :set $ISP2partialstate1 [/ping $HCaddr1 interval=$pingsinterval count=$pingscount routing-table=isp2_hc_rt] 
                :set $ISP2partialstate2 [/ping $HCaddr2 interval=$pingsinterval count=$pingscount routing-table=isp2_hc_rt]
                :set $ISP2partialstate3 [/ping $HCaddr3 interval=$pingsinterval count=$pingscount routing-table=isp2_hc_rt]
                
                :set $ISP2hpPrevious ($ISP2hpLatest)
                :set $ISP2hpLatest ($ISP2partialstate1 + $ISP2partialstate2 + $ISP2partialstate3)

                :if ($DebugIsOn) do={
                    :local ISP2hpLatestVarType [:typeof $ISP2hpLatest;]
                    :log warning ""
                    :log warning "$scriptname:  ISP2 healhpoint is $ISP2hpLatest"
                    :log warning "ISP2hpLatest vartype is $ISP2hpLatestVarType"
                    :log warning ""
                }

                } else={
                        # Displaying debug info, if DebuIsOn True
                        :if ($DebugIsOn) do={
                            :log warning ""
                            :log warning "$scriptname:  There is no ISP2 configured. Skipping and setting the ISP2hpLatest to 0."
                            :log warning ""
                        }
                        :set $ISP2hpLatest 0
                }

                # Passing state of the ISP3
                :if ($ISP3present) do={

                # Initializing global var for ISP3 healhpoints
                :global ISP3hpLatest
                :global ISP3hpPrevious
                
                # Debug info 
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname:  Checking health of the ISP3"
                    :log warning ""
                }

                # Local vars
                :local ISP3partialstate1
                :local ISP3partialstate2
                :local ISP3partialstate3

                # Checking the healthchecks and setting the ISPstate
                :set $ISP3partialstate1 [/ping $HCaddr1 interval=$pingsinterval count=$pingscount routing-table=isp3_hc_rt] 
                :set $ISP3partialstate2 [/ping $HCaddr2 interval=$pingsinterval count=$pingscount routing-table=isp3_hc_rt]
                :set $ISP3partialstate3 [/ping $HCaddr3 interval=$pingsinterval count=$pingscount routing-table=isp3_hc_rt]
                
                :set $ISP3hpPrevious ($ISP3hpLatest)
                :set $ISP3hpLatest ($ISP3partialstate1 + $ISP3partialstate2 + $ISP3partialstate3)

                # Debug info
                :if ($DebugIsOn) do={
                    :local ISP3hpLatestVarType [:typeof $ISP3hpLatest;]
                    :log warning ""
                    :log warning "$scriptname:  ISP3 healhpoint is $ISP3hpLatest"
                    :log warning "ISP3hpLatest vartype is $ISP3hpLatestVarType"
                    :log warning ""
                }

                } else={
                        # Displaying debug info, if DebuIsOn True
                        :if ($DebugIsOn) do={
                            :log warning ""
                            :log warning "$scriptname:  There is no ISP3 configured. Skipping and setting the ISP3hpLatest to 0."
                            :log warning ""
                        }
                        :set $ISP3hpLatest 0
                }

                :if ($DebugIsOn) do={
                :log warning ""
                :log warning "$scriptname: Reached end of the script..."
                :log warning "$scriptname: Looks like all good :)"
                :log warning ""


                # Alighing scheduler interval to the script runnign time

                        :global rosWHTScriptRunStartUptimeStamp
                        :global rosWHTScriptRunFinishUptimeStamp [/system resource get value-name=uptime]
                        :global rosWHTScriptRunTime 
                        :set $rosWHTScriptRunTime ($rosWHTScriptRunFinishUptimeStamp - $rosWHTScriptRunStartUptimeStamp)   



                # Showing the script running time in debug mode
                    :if ($DebugIsOn) do={
                                :log warning ""
                                :log warning "$scriptname:  rosWHTScriptRunStartUptimeStamp is $rosWHTScriptRunStartUptimeStamp"
                                :log warning "$scriptname:  rosWHTScriptRunFinishUptimeStamp is $rosWHTScriptRunFinishUptimeStamp"
                                :log warning "$scriptname:  rosWHTScriptRunTime is $rosWHTScriptRunTime"
                                :log warning ""
                    }

                # Incorrect scheduler interval fix

            :local currentISCinterval
            :set $rosWHTrunningInterval ($rosWHTScriptRunTime + 00:00:05)

                    # Displaying debug info, if DebuIsOn True
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname: intervaling debug point 1 pass :)"
                    :log warning "$scriptname: ISPcount is $ISPcount"
                    :log warning "$scriptname: rosWHTrunningInterval is $rosWHTrunningInterval"
                    :log warning ""
                }

            :do {
                :set $currentISCinterval [/system scheduler get value-name=interval [find where comment~"ros-wht_isc" && comment~"deamon"]]
                } on-error={
                    # Displaying debug info, if DebuIsOn True
                    :if ($DebugIsOn) do={
                        :log warning ""
                        :log warning "$scriptname:  Error when getting $scriptname scheduler interval."
                        :log warning "$scriptname: Perhaps, there is no configured scheduler."
                        :log warning ""
                        }
                    :do {
                        # Displaying debug info, if DebuIsOn True
                        :if ($DebugIsOn) do={
                            :log warning ""
                            :log warning "$scriptname: Adding the $scriptname scheduler..."
                            :log warning "$scriptname: Correct ISC interval is $rosWHTrunningInterval"
                            :log warning ""
                        }
                        /system scheduler add comment="$scriptname | deamon script | reccurently running on the automatically tuned interval" interval=$rosWHTrunningInterval name="$scriptname-deamon" policy=ftp,reboot,read,write,policy,test,password,sniff,sensitive,romon start-time=startup on-event="$scriptname" disabled=no
                            :if ($DebugIsOn) do={
                            :log warning ""
                            :log warning "$scriptname: The $scriptname scheduler succesfully added!"
                            :log warning ""
                        }
                    } on-error={
                            :if ($DebugIsOn) do={
                            :log error ""
                            :log error "$scriptname: Error when trying to add missing $scriptname scheduler."
                            :log error "$scriptname: Unexcpected Error. Code MSSA_ERROR"
                            :log error ""
                        }
                    }
                }

            :if ($currentISCinterval != $rosWHTrunningInterval) do={
                            
                            :if ($DebugIsOn) do={
                            :log warning ""
                            :log warning "$scriptname: The $scriptname scheduler interval was setted incorrect."
                            :log warning "$scriptname: ISC interval was set to $rosWHTrunningInterval"
                            :log warning ""
                            }
                /system scheduler set interval=$rosWHTrunningInterval [find where name~"$scriptname-deamon"]
            } else={
                            :if ($DebugIsOn) do={
                            :log warning ""
                            :log warning "$scriptname: The $scriptname scheduler interval is correct."
                            :log warning "$scriptname: Nothing need to be done with it"
                            :log warning ""
                            }
            }

            }
        } else={
                :if ($DebugIsOn) do={
                    :log warning ""
                    :log warning "$scriptname: ICP requested pause from ISC."
                    :log warning "$scriptname: So.. Waiting..."
                    :log warning ""
                }
                }
} else={

    :if ($DebugIsOn) do={
    :log warning ""
    :log warning "$scriptname: Duplication handler hit."
    :log warning "$scriptname: is still running, will not run another one"
    :log warning ""
}
}

