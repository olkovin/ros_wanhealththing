# Router OS WANhealththing
# t.me/olekovin
#
# Part of the overall script group
# Client ISP and VPN HUB state determiner part

# Global vars
:global cliISP2present
:global cliISP1state
:global cliISP2state
:global hubISP1state
:global hubISP2state
:global hubISP3state
:global DebugIsOn

### Passing state of the providers getted from netwatch to global vars
# Passing state of the CLI ISP1
:do {
    :set $cliISP1state [/tool netwatch get value-name=status [find where comment~"CLI-ISP1-watcher"]]
} on-error={
                :log error ""
                :log error "Error when setting cliISP1state"
                :log error "ERROR CODE: CISP1S_SET"
                :log error ""
}
# Passing state of the CLI ISP2, if it exists
:if ($cliISP2present) do={
    :do {
        :set $cliISP2state [/tool netwatch get value-name=status [find where comment~"CLI-ISP2-watcher"]]
    } on-error={
                :log error ""
                :log error "Error when setting cliISP2state"
                :log error "ERROR CODE: CISP2S_SET"
                :log error ""
    }
} else={
        :if (!$cliISP2present) do={
            :set $cliISP2state "down"
        } else={
                :log error ""
                :log error "Error when setting cliISP2state"
                :log error "ERROR CODE: CISP2S_SET_UNEXPECTED"
                :log error ""
        }
 }

 ## Passing state of the HUB ISPs
 # HUB ISP1
:do {
    :set $hubISP1state [/tool netwatch get value-name=status [find where comment~"HUB-ISP1-watcher"]]
} on-error={
            :log error ""
            :log error "Error when setting HUBISP1state"
            :log error "ERROR CODE: HISP1S_SET"
            :log error ""
}

 #HUB ISP2
:do {
    :set $hubISP2state [/tool netwatch get value-name=status [find where comment~"HUB-ISP2-watcher"]]
} on-error={
            :log error ""
            :log error "Error when setting HUBISP2state"
            :log error "ERROR CODE: HISP2S_SET"
            :log error ""
}

 #HUB ISP3
:do {
    :set $hubISP3state [/tool netwatch get value-name=status [find where comment~"HUB-ISP3-watcher"]]
} on-error={
            :log error ""
            :log error "Error when setting HUBISP3state"
            :log error "ERROR CODE: HISP3S_SET"
            :log error ""
}