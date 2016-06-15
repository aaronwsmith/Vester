#requires -Modules VMware.VimAutomation.Core
#requires -Version 1 -Modules Pester

Invoke-Expression -Command (Get-Item -Path 'Config.ps1')
[array]$esxdns = $global:config.host.esxdns
[array]$searchdomains = $global:config.host.searchdomains

Describe -Name 'Host Configuration: DNS Server(s)' -Fixture {
    foreach ($server in (Get-VMHost)) 
    {
        It -name "$($server.name) Host DNS Address" -test {
            [array]$value = (Get-VMHostNetwork -VMHost $server).DnsAddress
            try 
            {
                Compare-Object -ReferenceObject $esxdns -DifferenceObject $value | Should Be $null
            }
            catch 
            {
                Write-Warning -Message "Fixing $server - $_"
                Get-VMHostNetwork -VMHost $server | Set-VMHostNetwork -DnsAddress $esxdns
            }
        }
        It -name "$($server.name) Host DNS Search Domain" -test {
            [array]$value = (Get-VMHostNetwork -VMHost $server).SearchDomain
            try 
            {
                Compare-Object -ReferenceObject $searchdomains -DifferenceObject $value | Should Be $null
            }
            catch 
            {
                Write-Warning -Message "Fixing $server - $_"
                Get-VMHostNetwork -VMHost $server | Set-VMHostNetwork -SearchDomain $searchdomains
            }
        }
    }
}