{
:local app "App_OVPNSRV_v0.3"
:log info "$app:started"



:local dryrun false
:local SETbr false
:local SETip false
:local SETpool false
:local SETfw false
:local SETcrt true
:local SETovpnsrv false
:local SETcrl true


:local CAname "MYCA01"
:local CAcountry "CA"
:local CAstate "BC"
:local CAlocality "WV"
:local CAorg "Company"
:local CAunit "Sysadmin"
:local CAcommonname "MYCA01-common"
:local CAcommonname "domain.dyn-payam124.com"
:local CAkeysize "4096"
#days, 10years
:local CAvalidity "3650" 
#certificate revocation list
:local CAcrlhost "127.0.0.1"

:local SRVname "SERVER"

:local CL01name "CLIENT-01"
:local CL01commonname "CLIENT01"
:local CL01exportpass "12345678"


:local SRVBRIP "192.168.211.1/24"
:local VPNPool "192.168.211.100-192.168.211.200"
:local NATRange "192.168.211.0/24"


:local OVPNPort "1194"
#v6, does not support gcm
:local OVPNCiphers ""
:set OVPNCiphers "aes128-cbc,aes192-cbc,aes256-cbc"
:set OVPNCiphers "aes128-gcm,aes192-gcm,aes256-gcm"
:set OVPNCiphers "aes128-cbc,aes192-cbc,aes256-cbc,aes128-gcm,aes192-gcm,aes256-gcm"


:local logmsg "$app: script started"
:put $logmsg
:log info $logmsg

:local CRTs {$CAname; $SRVname; $CL01name}
:local hasError false
:foreach CRT in=$CRTs do={
   :if ([:len [/certificate find where name="$CRT"]] >0) do={ 
      :put "====>$CRT<====== exit. first delete it"
      :put ""
      /certificate print detail where name="$CRT"
      :put ""
      :set hasError true
      }
}

:if ($SETbr) do={
   :local cmd ("/interface bridge add name=bridge-vpn")
   :local logdata "$app: setting Bridge interface"
   :if ($dryrun) do={
       :put ("#" . $logdata)
       :put $cmd
   } else={
       :log info  ($app . ": " . $logdata )
       [:parse $cmd]
   }
}

:if ($SETip) do={ 
   :local cmd ("/ip address add address=".$SRVBRIP." interface=bridge-vpn")
   :local logdata "$app: setting IP address for bridge"
   :if ($dryrun) do={
       :put ("#" . $logdata)
       :put $cmd
   } else={
       :log info  ($app . ": " . $logdata )
       [:parse $cmd]
   }
}

:if ($SETpool) do={
   :local cmd ("/ip pool add name=pool-vpn ranges=".$VPNPool)
   :local logdata "setting VPN Pool"
   :if ($dryrun) do={
       :put ("#" . $logdata)
       :put $cmd
   } else={
       :log info  ($app . ": " . $logdata )
       [:parse $cmd]
   }
}

:if ($SETfw) do={
   :local cmds [:toarray ""]
   :local cmd1  ("/ip firewall filter add chain=input action=accept comment=\"#MLK#OVPN pass\" protocol=udp dst-port=1194")
   :if ([:len [/ip firewal filter find]] >0) do={ 
      :set $cmd1 ($cmd1." place-before=1")
   }
   :set ($cmds->0)  $cmd1
   :set ($cmds->1)  ("/ip firewall nat add chain=srcnat src-address=$NATRange  comment=\"#MLK#OVPN NAT\" action=masquerade")
   :local logdata "setting firewall"
   :if ($dryrun) do={
       :put ("#" . $logdata)
       :foreach cmd in=$cmds do={
          :put $cmd
        }
   } else={
       :log info  ($app . ": " . $logdata )
       :foreach cmd in=$cmds do={
          [:parse $cmd]
       }
   }
}


:if ($SETcrt) do={
   :local cmds [:toarray ""]
   :local logs [:toarray ""]


   :set ($cmds->0)  ("/certificate add name=\"$CAname\" country=\"$CAcountry\" state=\"$CAstate\" \
 locality=\"$CAlocality\" organization=\"$CAorg\" unit=\"$CAunit\" \
 common-name=\"$CAcommonname\" key-size=$CAkeysize days-valid=$CAvalidity \
 key-usage=crl-sign,key-cert-sign")

   :set ($logs->0) "generate CA"



   :set ($cmds->1)  ("/certificate sign \"$CAname\" ca-crl-host=\"$CAcrlhost\"")
   :set ($logs->1)  "sign CA"


   #Could use different parameters compared to CA
   :set ($cmds->2)  ("/certificate add name=\"$SRVname\" country=\"$CAcountry\" state=\"$CAstate\" \
 locality=\"$CAlocality\" organization=\"$CAorg\" unit=\"$CAunit\" \
 common-name=\"127.0.0.1\" key-size=$CAkeysize days-valid=$CAvalidity \
 key-usage=digital-signature,key-encipherment,tls-server")

   :set ($logs->2) ("generate Server CRT")

   :set ($cmds->3)  ("/certificate sign $SRVname ca=\"$CAname\"") 
   :set ($logs->3)  ("sing Server certificate")

   :set ($cmds->4)  ("/certificate set \"$SRVname\" trusted=yes")
   :set ($logs->4)  ("trust server certificate")

   :set ($cmds->5)  ("/certificate add name=\"$CL01name\" country=\"$CAcountry\" state=\"$CAstate\" \
 locality=\"$CAlocality\" organization=\"$CAorg\" unit=\"$CAunit\" \
 common-name=\"$CL01commonname\" key-size=$CAkeysize days-valid=$CAvalidity \
 key-usage=tls-client")

   :set ($logs->5)  ("generate client ceritifate")
   
   :set ($cmds->6)  ("/certificate sign $CL01name ca=\"$CAname\"")
   :set ($logs->6)  ("sing client certificate")

   :set ($cmds->7)  ("/certificate export-certificate $CAname  export-passphrase=\"\"")
   :set ($logs->7)  ("export CA")

   :set ($cmds->8)  ("/certificate export-certificate $CL01name export-passphrase=\"$CL01exportpass\"")
   :set ($logs->8)  ("export client ceritificate")

   


:for count from=0 to=[:len $cmds] do={
   :local cmd ($cmds->$count)
   :local logdata ($logs->$count)
   :if ($dryrun) do={
       :put ("#" . $logdata)
       :put $cmd
   } else={
       :log info  ($app . ":" . $logdata )
       [:parse $cmd]
   }
   
}

:put "=========================================="
:put "#copy cert_export_$CL01name.crt out"
:put "#copy cert_export_$CL01name.key out"
:put "#copy cert_export_$CAname.crt out"
:put "#decrypt client private key on PC or import it on another MikroTik"
:put "#openssl rsa -in cert_export_$CL01name.key -out cert_export_$CL01name.decrypted.key"
:put "#/certificate import file-name=cert_export_$CAname.crt name=$CAname"
:put "#/certificate/import file-name=cert_export_$CL01name.crt name=$CL01name"
:put ("#/certificate/import file-name=cert_export_$CL01name.key passphrase=".$CL01exportpass." name=$CL01name")

}

:if ($SETcrl) do={
   :local crlidstr [:pick [/certificate/find where name="$CAname"] 0 ]
   :local crlid  [:tonum ("0x".[:pick $crlidstr 1 [:len $crlidstr]])]
   :local cmd ("/certificate crl add url=http://$CAcrlhost/crl/".$crlid.".crl; /certificate crl download ")
   :local logdata "adding crl"   

   :if ($dryrun) do={
       :put ("#" . $logdata)
       :put $cmd
   } else={
       :log info  ($app . ": " . $logdata )
       [:parse $cmd]
   }


}

#version 6, does not support gcm
:if ($SETovpnsrv) do={
   :local cmds [:toarray ""]
   :local logs [:toarray ""]

   :set ($cmds->0) ("/interface ovpn-server server" . \
               " set auth=sha1 certificate=$SRVname cipher=aes128-cbc,aes192-cbc,aes256-cbc " . \
               "default-profile=default-encryption enable-tun-ipv6=no enabled=yes ipv6-prefix-len=64 ". \
               "keepalive-timeout=60  max-mtu=1500 mode=ip netmask=24 port=$OVPNPort " . \
               "protocol=tcp redirect-gateway=disabled reneg-sec=3600 require-client-certificate=yes " . \
               "tls-version=any tun-server-ipv6=::")
   :set ($logs->0) "setting up openvpn server"

   :set ($cmds->1) ("/ppp profile add bridge=bridge-vpn local-address=$SRVBRIP name=profile_ovpn remote-address=pool-vpn")
   :set ($logs->1) ("adding ppp profile")

   :for count from=0 to=[:len $cmds] do={
      :local cmd ($cmds->$count)
      :local logdata ($logs->$count)
      :if ($dryrun) do={
         :put $logdata
         :put $cmd
       } else={
         :log info  ($app . ":" . $logdata )
         [:parse $cmd]
      }
   }


}
:log info ($app  . ": finishd")
}

