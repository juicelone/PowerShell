# Get server names from file
$server_names = Get-Content "C:\Zabbix_agent_share\hosts.txt"
# Date for report
$Rundate = Get-Date -Format "dd.MM.yyyy-HH.mm"
$(
Foreach ($server in $server_names)
{
    $server_n = $server
    # Set locations of Zabbix Agent files
    $source = "C:\Zabbix_agent_share\Agent-4.4.0-win-x64"
    $target = "\\$server_n\C$\Program Files\Zabbix Agent\"
    # Check if server is reachable
    $chconn = Test-Connection -Cn $server_n -Count 1 -Quiet
    if ($chconn)
    {
        $date = Get-Date -Format "dd.MM.yyyy HH:mm";
        Write-Host 'Working on'$server_n 'at' $date -ForegroundColor Red -BackgroundColor White;
        # Copy Zabbix Agent files
        xcopy $source $target /O /X /E /H /K /D /Y;
        $date = Get-Date -Format "dd.MM.yyyy HH:mm";
        Write-Host 'Files copy success on'$server_n 'at' $date -ForegroundColor DarkGreen -BackgroundColor White
        # Start deploy script on remote host
        Invoke-Command -ComputerName $server_n -ScriptBlock { 
            # Check if Zabbix Agent is installed and running, if not start the service.
            If (get-service -Name "Zabbix Agent" -ErrorAction SilentlyContinue | Where-Object -Property Status -eq "Running")
            {
                Write-host 'Zabbix agent is already installed and running'
                Exit
            }
            Elseif (get-service -Name "Zabbix Agent" -ErrorAction SilentlyContinue | Where-Object -Property Status -eq "Stopped") 
            {
                # Starts service if it exists in a Stopped state.
                Write-host 'Zabbix agent installed, but not running. Starting service...'
                Start-Service "Zabbix Agent"    
                Exit
            }
            # Create firewall rule
            New-NetFirewallRule -DisplayName "Zabbix Agent Allow" -Direction Inbound -LocalPort Any -Protocol Any -Program "C:\Program Files\Zabbix Agent\bin\zabbix_agentd.exe" -Action Allow
            # Create service
            New-Service -Name "Zabbix Agent" -BinaryPathName "C:\Program Files\Zabbix Agent\bin\zabbix_agentd.exe --config C:\Program Files\Zabbix Agent\conf\zabbix_agentd.conf" -DisplayName "Zabbix Agent" -Description "Provides system monitoring" -StartupType "Automatic" -ErrorAction SilentlyContinue
            # Start service
            (Get-WmiObject win32_service -Filter "name='Zabbix Agent'").StartService()
            #Start-Service "Zabbix Agent"
        }
    }
    else
    {
        Write-Host $server_n 'unreachable' -ForegroundColor Black -BackgroundColor White
    }
}) *>&1 > "C:\Zabbix_agent_share\Reports\Report_$Rundate.txt"