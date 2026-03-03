# Andrew Rucks
# 3/3/26
# For CIT 241  - Systems Programming
# CALCULATE BROADCAST OR NETWORK ID

function Main ()
{
    echo "The following operations are available...
    `t1. Calculate a broadcast address. You will need the subnet mask and network ID.
    `t2. Calculate a network ID. You will need a host ID and the subnet mask.`n"

    # determine user's choice for which function to use
    switch (Read-Host -Prompt "Choose the operation you want by entering a number from above")
    {
        "1" {Calculate-Broadcast}
        "2" {Calculate-Network}
        default
        {
            echo "!!! Invalid option selected.`n"
            Main #restarts script
        }
    }
}

function Calculate-Broadcast ()
{
    echo "Selected broadcast address"

    # ask for network ID and network mask
    $netid, $netmask = Ask-Addresses "network ID" "network/subnet mask"

    # calculates broadcast address
    $bc = [ipaddress]"1.1.1.1" #creates basic IP address object
    $bc.Address = ((-BNOT $netmask.Address) -BOR ($netid.Address)) #performs bitwise operations on the integer forms of addresses to get broadcast addr. then uses IP object to convert to string

    # prints results
    echo "`nResult (Broadcast Address): $($bc.IPAddressToString)"
}

function Calculate-Network ()
{
    echo "Selected network ID"

    # asks for host address and network mask
    $hostaddr, $netmask = Ask-Addresses "host address" "network/subnet mask"

    # calculates network ID
    $nid = [ipaddress]"1.1.1.1" #creates basic IP address object
    $nid.Address = ($hostaddr.Address -BAND $netmask.Address) #performs bitwise operations on the integer forms of addresses to get network ID. then uses IP object to convert to string

    # prints results
    echo "`nResult (Network ID): $($nid.IPAddressToString)"
}

function Ask-Addresses ($prompt1, $prompt2)
{
    # repeatedly asks for addresses until they are given in the right format.
    do
    {
        try #to convert to IP address type
        {
            [ipaddress]$addr1 = Read-Host -Prompt "Enter the $prompt1 (xxx.xxx.xxx.xxx)"
            [ipaddress]$addr2 = Read-Host -Prompt "Enter the $prompt2 (xxx.xxx.xxx.xxx)"
            $ipisvalid = $true
        }
        catch
        {
            Write-Host "!!! Error: IP address formatted incorrectly. Please try again...`n"
        }
    }
    until ($ipisvalid)

    return @($addr1, $addr2)
}

# calls first function
Main