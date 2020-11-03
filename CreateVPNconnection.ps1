#---Enter vpn server address, connection name, domain suffix, DNS servers, VPN connection type
$ServerAddress = "vpn.contoso.com"
$ConnectionName = "Contoso-VPN"
$DomainSuffix = "contoso.com"
$DNSservers = "192.168.100.1", "192.168.200.1"
$VPNtype = "PPTP"
#---Enter subnets you whant to reach. Routes to them will be added while VPN is connected
$Destination = "192.168.100.0/24"
$Destination2 = "192.168.200.0/24"
#---To create VPN connection for all users or only for current, choose one of next 2 strings
#---Add-VpnConnection -Name "$ConnectionName" -ServerAddress "$ServerAddress" -TunnelType "$VPNtype" -EncryptionLevel "Optional" -AuthenticationMethod MSChapv2 -DnsSuffix $DomainSuffix -SplitTunneling -RememberCredential -PassThru -AllUserConnection
Add-VpnConnection -Name "$ConnectionName" -ServerAddress "$ServerAddress" -TunnelType "$VPNtype" -EncryptionLevel "Optional" -AuthenticationMethod MSChapv2 -DnsSuffix $DomainSuffix -SplitTunneling -RememberCredential -PassThru
Add-Vpnconnectionroute -Connectionname $ConnectionName -DestinationPrefix $Destination -RouteMetric 30 -PassThru
Add-Vpnconnectionroute -Connectionname $ConnectionName -DestinationPrefix $Destination2 -RouteMetric 30 -PassThru
Add-VpnConnectionTriggerDnsConfiguration -ConnectionName $ConnectionName -DnsIPAddress $DNSservers -DnsSuffix $DomainSuffix -PassThru -Force
Set-VpnConnectionTriggerDnsConfiguration -ConnectionName $ConnectionName -DnsIPAddress $DNSservers -DnsSuffix $DomainSuffix -PassThru -Force
#---Next script block is used to fix the problem, when newly created connection will use current user credentials to auth on remote network resources by default
#---To create VPN connection for all users or only for current, choose one of next 2 strings
#$pbkpath = Join-Path $env:PROGRAMDATA "Microsoft\Network\Connections\Pbk\rasphone.pbk"
$pbkpath = Join-Path $env:APPDATA "Microsoft\Network\Connections\Pbk\rasphone.pbk"
(Get-Content -path $pbkpath -Raw) -Replace 'UseRasCredentials=1','UseRasCredentials=0' | Set-Content -path $pbkpath