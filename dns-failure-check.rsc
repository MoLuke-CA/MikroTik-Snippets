#https://www.reddit.com/r/mikrotik/comments/17ujpu5/how_do_fix_the_loop_in_mikrotik_script/
{
    :local app "#####DNS CHECKER by MoLuke.net/v01"
    :log info "$app started"
    #sample: 1 failure
    #:local testDomains {"www.google.com";"www.facebook.com";"www.xccg.co","www.youtube.com"}
    #sample:‌ all failure
    :local testDomains {"notexisteddomain1.edu";"wwww.nonexistingdwrongdomain.com"}
    #sample:‌ all failure except one failure
    :local testDomains {"notexisteddomain1.edu";"wwww.nonexistingdwrongdomain.com";"www.google.com"}
    

    :local piholeDNS "1.1.1.1"
    :local MaxAcceptedFailure 0
    #0-> everythin, should work, 1-> single failure is still accepted, 
    
    :local FailureCount 0

    :foreach i in $testDomains do={
        :do {
            :resolve $i server $piholeDNS
            } on-error={
                :log info "failure in resolving $i through $piholeDNS"
                :set $FailureCount ($FailureCount + 1)
            }
    }
    if ($FailureCount > $MaxAcceptedFailure) do={
        :local msg "the maximum defined failure passed"
        :log info $msg
        :put $msg
    }
    if ($FailureCount = [:len $testDomains]) do={
        :local msg "all attempts failed"
        :log info $msg
        :put $msg
    }
    :log info "$app finished"
    
}