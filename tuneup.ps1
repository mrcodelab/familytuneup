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
    Set-Location $HOME
    Clear-RecycleBin -Force
    Write-Host "Recycle Bin cleaned - Ignore the error. It works."
    Set-Location $HOME\Downloads
    Remove-Item -Recurse *
    Remove-Item c:\Windows\Temp\* -Recurse -Force -ErrorAction SilentlyContinue
    $PSScriptRoot
    Start-Process -FilePath "C:\WINDOWS\system32\cleanmgr.exe" /sagerun:1 | Out-Null
    Wait-Process -Name cleanmgr
    Start-Process -FilePath "C:\Program Files (x86)\Wise\Wise Registry Cleaner\WiseRegCleaner.exe"
    }


function common {
    Write-Host "Updating the maintenance and security files"
    Invoke-WebRequest -Uri https://github.com/schwastedotter/homegym/blob/main/zAdmin/tuneup.ps1 -OutFile 'C:\Program Files\zAdmin\tuneup.ps1'
    #Invoke-WebRequest -Uri https://github.com/schwastedotter/homegym/blob/main/zAdmin/hosts -OutFile 'C:\Windows\System32\drivers\etc\hosts'
    Write-Host "Updating Windows"
    updater
    Write-Host "Cleaning up the system bloat"
    cleanup
    stateTogg
    Set-Location $HOME
}

Write-Output "Running common workload"
common

$PSScriptRoot

if (( $u -eq "mateusz" ) -and ( $mo -in $sched )) {
    Write-Output "running admin special"
    & "$PSScriptRoot\pwmaintenance.ps1"
    } else { Write-Output "Not now Madeline" }


Stop-Process -Name powershell
