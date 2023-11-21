try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} catch {
    Write-Error "Outdated operating systems are not supported."
    Exit 1
}

$file = 'aria2c.exe'
$url = 'https://uupdump.net/misc/aria2c.exe';
$hash = '0ae98794b3523634b0af362d6f8c04a9bbd32aeda959b72ca0e7fc24e84d2a66';

function Test-Existece {
    param (
        [String]$File
    )

    return Test-Path -PathType Leaf -Path "files\$File"
}

function Retrieve-File {
    param (
        [String]$File,
        [String]$Url
    )

    Write-Host -BackgroundColor Black -ForegroundColor Yellow "Downloading ${File}..."
    Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile "files\$File" -ErrorAction Stop
}

function Test-Hash {
    param (
        [String]$File,
        [String]$Hash
    )

    Write-Host -BackgroundColor Black -ForegroundColor Cyan "Verifying ${File}..."

    $fileHash = (Get-FileHash -Path "files\$File" -Algorithm SHA256 -ErrorAction Stop).Hash
    return ($fileHash.ToLower() -eq $Hash)
}

if((Test-Existece -File $file) -and (Test-Hash -File $file -Hash $hash)) {
    Write-Host -BackgroundColor Black -ForegroundColor Green "Ready."
    Exit 0
}

if(-not (Test-Path -PathType Container -Path "files")) {
    $null = New-Item -Path "files" -ItemType Directory
}

try {
    Retrieve-File -File $file -Url $url
} catch {
    Write-Host "Failed to download $file"
    Write-Host $_
    Exit 1
}

if(-not (Test-Hash -File $file -Hash $hash)) {
    Write-Error "$file appears to be tampered with"
    Exit 1
}

Write-Host -BackgroundColor Black -ForegroundColor Green "Ready."
