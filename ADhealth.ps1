
function Get-DCsinForest {

$domains = Get-ADForest | Select -ExpandProperty Domains
$DClist = @()
foreach ($domain in $domains)
{

$dinfo = Get-ADDomain $domain
$DCs = $dinfo.ReplicaDirectoryServers
$DClist += $DCs
}

return $DClist

}

function Write-Success 
{
param( 
 [String] $text

)

Write-Host "$text" -ForegroundColor Green

}

function Write-Failure
{
param( 
 [String] $text

)

Write-Host "$text" -ForegroundColor Red

}



$DCs = Get-DCsinForest
foreach ($DC in $DCs )
{

Write-Host "Domain Controller : $DC"
Write-Host "Test 1 : Connectivity"
Write-Host "-------------------------"
Write-Host "a) Ping : "

        if (Test-Connection $DC -Count 1 -Quiet)
        {
            Write-Success "$DC : Success"
        }
        else
        {
            Write-Failure "$DC : Failure ( Cannot connect over ping - other tests are skipped)"
            continue
        }
Write-Host "b) Ports : "
$Ports  = "135","389","636","3268","53","88","445","3269"

        Foreach ($P in $Ports){
        $check=Test-NetConnection $DC -Port $P -WarningAction SilentlyContinue
        If ($check.tcpTestSucceeded -eq $true)
        {Write-Success "$DC on Port $P"}
        else
        {Write-Failure "$DC on Port $P"}
        }
}

