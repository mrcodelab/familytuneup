$u=$env:UserName
#$c=$env:COMPUTERNAME
Write-Output "Hi $u. "
#$b="C:\Program Files\zAdmin"
$mo=Get-Date -UFormat %b
$sched = "Jan", "Mar", "May", "Jul", "Sep", "Nov"
$task = Read-Host "Do you need a reboot (r) || shutdown(s) || keep awake(k)"

function stateTogg {    
    if ( $task -eq "s" ) {
        Stop-Computer
        } 
    elseif ($task -eq 'r') {
        Restart-Computer
        }
    else { Write-Host "Keeping awake"}
}

function updater {
    Get-WUInstall -Install -AcceptAll -AutoReboot
    Get-WUInstall -MicrosoftUpdate -Install -AcceptAll -AutoReboot
    }

function cleanup {
    Clear-RecycleBin -DriveLetter C -Force
    Set-Location $HOME\Downloads
    Remove-Item -Recurse *
    Remove-Item c:\Windows\Temp\* -Recurse -Force -ErrorAction SilentlyContinue
    $PSScriptRoot
#    cleanmgr /sagerun:1 | out-Null
    Start-Process -FilePath "C:\WINDOWS\system32\cleanmgr.exe" /sagerun:1 | Out-Null
    Wait-Process -Name cleanmgr
    Start-Process -FilePath "C:\Program Files (x86)\Wise\Wise Registry Cleaner\WiseRegCleaner.exe"
    }


function common {
    updater
    cleanup
    stateTogg
    Exit-PSSession
}

Write-Output "Running common workload"
common

$PSScriptRoot

if (( $u -eq "mateusz" ) -and ( $mo -in $sched )) {
    Write-Output "running admin special"
    & "$PSScriptRoot\pwmaintenance.ps1"
    } else { Write-Output "Not now Madeline" }