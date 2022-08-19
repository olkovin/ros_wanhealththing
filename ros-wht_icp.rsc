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
:global ISP2present
:global ISP3present
:global ISPhpGood
:global CurrentISP
:global DebugIsOn

# Local vars
:local scriptname "ros-wht_icp"


##### DUPLICATION HANDLER#####
:if ([/system script job print as-value count-only where script="rwsv-cist"] <= 1) do={

###
### ISP1 actions handler
### 

:if ($ISP1present) do={

    # When we do have ISP1, let's initialize corresponding global vars
        :global ISP1hp
        :global ISP1type

    :if (($ISPhpGood - $ISP1hp) > 1) do={
        # Actions when ISP1 is not good
        :if ($ISP1type = "STATIC") do={
            # ISP1 not good and static
            :if
            /ip route set distance 
        } else={
            #ISP1 not good and not static
        }

        :if ($ISP1type = "DHCP") do={
            # ISP1 not good and static
        } else={
            #ISP1 not good and not DYNAMIC
        }

        # Remove all connectios for the faster reconnection via new isp
        /ip firewall connection remove [find where src-address!=127.0.0.1:0]

    } else={
        :if (($ISPhpGood - $ISP1hp) <= 1) do={
            # Actions when ISP1 is good
            
            :if ($ISP1type = "STATIC") do={
            # ISP1 good and static
            }

            :if ($ISP1type = "DHCP") do={
            # ISP1 good and DHCP
            }

        # Remove all connectios for the faster reconnection via new isp
        /ip firewall connection remove [find where src-address!=127.0.0.1:0]
        
        }

    } else={
        # Some exceptions catcher
    }

    }

###
#######
###

###
### ISP2 actions handler
### 
###
#######
###

###
### ISP3 actions handler
### 
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