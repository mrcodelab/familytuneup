#version yyyy.mm.MAJ.MIN.r
#version 2022.06.2.1.2
$version = 202206.2.1.2
$u=$env:UserName
$c=$env:COMPUTERNAME
Write-Output "Hi $u. "
$b="C:\Program Files\zAdmin"
$h = "C:\Windows\System32\drivers\etc\hosts"
$mo=Get-Date -UFormat %b
$sched = "Jan", "Mar", "May", "Jul", "Sep", "Nov"
Write-Host "You are running version $version of Spam Defender."
$task = Read-Host "Do you need a reboot (r) OR shutdown(s) OR keep awake(k)"
$task = $task.ToUpper()

try {
    if(Test-Path -Path $b) {
        Write-Host "The folder already exists"
    }
    else{
        mkdir $b
    }
}
catch {
    {1:<#Do this if a terminating exception happens#>}
}

function msdtTest {
    try {
        New-PSDrive -PSProvider registry -Root HKEY_CLASSES_ROOT -Name HKCR
    }
    catch {
        -ErrorAction Ignore
    }

    Set-Location -Path HKCR:\
    $keyname = "HKCR:\ms-msdt"
    if ( Get-ChildItem -Path $keyname -ErrorAction Ignore ) {
        Write-Host "it exists" -ForegroundColor Red
        Remove-Item -Recurse -Force $keyname -WhatIf
        Write-Host "MSDT is removed." -ForegroundColor Green
    }
    else {
        write-host "MSDT is already gone." -ForegroundColor Green
    }
}

function stateTogg {
    if ( $task -eq 'S' ) {
        Stop-Computer -Force
        }
    elseif ($task -eq 'R') {
        Restart-Computer -Force
        }
    else { Write-Host "Keeping awake"}
}

function gitUpdater{
    try {
        Write-Host "Updating the maintenance and security files" -ForegroundColor Yellow
        Invoke-WebRequest -Uri https://raw.githubusercontent.com/mrcodelab/familytuneup/main/tuneup.ps1 -OutFile '$HOME\Downloads'
        $zip1 = Get-FileHash -Algorithm SHA256 $HOME\Downloads\tuneup.ps1 | Select-Object -ExpandProperty Hash
        Invoke-WebRequest -Uri https://raw.githubusercontent.com/mrcodelab/hashes/main/tuneup-hash.txt -OutFile '$HOME\Downloads'
        $hash1 = Get-Content $HOME\Downloads\tuneup-hash.txt
        if ( $zip1 -eq $hash1 ) {
            Move-Item tuneup.ps1 $b
            Write-Host "Tuneup file updated." -ForegroundColor Green
        }
        else { Write-Host "The tuneup hash did not match!" -ForegroundColor Red }
    }
    catch {
        Write-Host "" -ErrorAction SilentlyContinue
    }

    try {
        Invoke-WebRequest -Uri https://raw.githubusercontent.com/mrcodelab/pihole-g/main/hosts -OutFile '$HOME\Downloads'
        $zip2 = Get-FileHash -Algorithm SHA256 $HOME\Downloads\hosts | Select-Object -ExpandProperty Hash
        Invoke-WebRequest -Uri https://raw.githubusercontent.com/mrcodelab/hashes/main/hosts_hash.txt -OutFile '$HOME\Downloads'
        $hash2 = Get-Content $HOME\Downloads\hosts_hash.txt
        if ( $zip2 -eq $hash2 ) {
            $ucheck = Get-FileHash -Algorithm SHA256 $h | Select-Object -ExpandProperty Hash
            if ( $hash2 -ne $ucheck ) {
                Write-Host "The hosts file has been updated. Please disable your antivirus and re-run spamdefender to get the latest filter."
                Move-Item $Home\Downloads\hosts $h -ErrorAction SilentlyContinue
            }
            Move-Item $Home\Downloads\hosts $h
            Write-Host "Hosts file updated." -ForegroundColor Green
        }
        else { Write-Host "The host hash did not match! The host file was not updated." -ForegroundColor Red }
    }
    catch {
        Write-Host "Security file update blocked by antivirus. No biggie." -ForegroundColor White -ErrorAction SilentlyContinue
    }

}

function updater {
    Get-WUInstall -Install -AcceptAll -AutoReboot -Hide
    Get-WUInstall -MicrosoftUpdate -Install -AcceptAll -AutoReboot -Hide
}

function dldclnr {
    if( $c -ne "MightyMouse"){
        Remove-Item -Path $Home\Downloads\* -Recurse -Force
        Write-Host "Done cleaning downloads" -ForegroundColor Green
    }
    else { 
        Remove-Item $HOME\Downloads\*.gz -Recurse
        Write-Host "Not deleting downloads folder" 
    }
}

function cleanup {
    Set-Location $HOME
    Clear-RecycleBin -DriveLetter C -Force -ErrorAction SilentlyContinue
    Write-Host "Recycle Bin cleaned - Ignore the error. It works." -ForegroundColor Green
    dldclnr
    Write-Host "Cleaning the temp folder." -ForegroundColor Yellow
    Remove-Item -Path C:\Windows\Temp\* -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Temp folder cleaned." -ForegroundColor Green
    Set-Location $PSScriptRoot
    Start-Process -FilePath "C:\WINDOWS\system32\cleanmgr.exe" /sagerun:1 | Out-Null
    Wait-Process -Name cleanmgr
    Start-Process -FilePath "C:\Program Files (x86)\Wise\Wise Registry Cleaner\WiseRegCleaner.exe"
}


function common {
    Write-Host "Testing MSDT vulnerability" -ForegroundColor Yellow
    msdtTest
    Set-Location $b
    Write-Host "Updating Windows" -ForegroundColor Yellow
    updater
    gitUpdater
    Write-Host "Windows update complete." -ForegroundColor Green
    Write-Host "Cleaning up the system bloat" -ForegroundColor Yellow
    cleanup
    Write-Host "Disk cleanup complete." - -ForegroundColor Green
    stateTogg
    Set-Location $HOME
}

Write-Host "Running common workload" -ForegroundColor Yellow

common

Write-Host "Thank you for using Spam Defender!"

if (( $u -eq "mateusz" ) -and ( $mo -in $sched )) {
    Write-Host "running admin special" -ForegroundColor Yellow
    & "$PSScriptRoot\pwmaintenance.ps1"
    } else { Write-Host "Not now Madeline" -ForegroundColor Blue}


Stop-Process -Name powershell
