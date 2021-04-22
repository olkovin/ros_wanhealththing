# wanhealththing
# Determination of current and next default ISP

# get preprocessing values in local temp memory
    :local ispdeterm1 [ip route get value-name=comment number=[find where distance=11]]
    :local ispdeterm2 [ip route get value-name=comment number=[find where distance=22]]
    
# strip values and put filtered data to global vars
    :global currentISP [:pick $ispdeterm1 3 7]
    :global nextbackupISP [:pick $ispdeterm2 3 7]