# DNS Query Monitor Script
#run with powershell -ExecutionPolicy Bypass -File dns-monitor.ps1

# Configuration
$logPath = "C:\DNSQueryLog.txt"
$intervalSeconds = 300  # Check every 5 minutes

function Get-DNSQueries {
    Get-WinEvent -FilterHashtable @{
        LogName = 'DNS Server'
        ID = 256  # DNS query events
    } -MaxEvents 100 | 
    Select-Object TimeCreated, 
                  @{Name='QueryName';Expression={$_.Properties[0].Value}},
                  @{Name='QueryType';Expression={$_.Properties[1].Value}},
                  @{Name='ClientIP';Expression={$_.Properties[4].Value}}
}

while ($true) {
    $queries = Get-DNSQueries
    $queries | Format-Table -AutoSize | Out-File -FilePath $logPath -Append
    Write-Host "DNS queries logged. Waiting for next check..."
    Start-Sleep -Seconds $intervalSeconds
}
