param(
  [String]$driveLett = "$env:driveLetter",
  [String]$driveLoc = "$env:driveLocation",
  [String]$user = "$env:userNam3",
  [String]$pass = "$env:passw0rd",
  [string]$driveNam = "$env:driveName")

$ourMap = $drivelett += ':'
$findMaps = Get-wmiobject Win32_MappedLogicalDisk | select-object name -expandproperty name

function Start-DriveCheck {
    try {
        Write-Host "`n Please see below for the current mapped drives under command --net use--`n"
        net use
        Exit-PSHostProcess
    }
    catch {
        Write-Warning "Something happened while using command --net use--...Exiting Script"
        Exit-PSHostProcess
    }
}


function Start-CredentialMGMT {
    try {
        $driveloc2 = $driveLoc.replace('\','')
        cmdkey /add:"$driveLoc2" /user:$user /pass:$pass
    }catch{
        Write-Error "`nSomething happened while installing Credential Manager Module...Continuing but the user's credentials will not be stored in the Credential Manager...`n"
        Exit-PSHostProcess
    }
    Start-DriveCheck
}


function start-map{
    try {
        Write-Host "`nMapping the drive $ourMap at location $driveLoc`n"
        if($null -eq $user -or $null -eq $pass){
            net use $OurMap $driveLoc /persistent:yes
        }else{
            net use $OurMap $driveLoc /u:$user $pass /persistent:yes
        }
   }
   catch {
        Write-Warning "`nSomething happened while mapping the drive at $OurMap$OurLoc`n"
        Write-Host $_
        Exit-PSHostProcess
   }
   try {
        $rename = new-object -ComObject Shell.Application
        $rename.NameSpace("$ourMap").Self.Name = "$driveNam"
   }
   catch {
        Write-Warning "`nSomething happened while renaming $ourMap to $driveNam`n"
        Write-Host $_
        Exit-PSHostProcess
   }
   Start-CredentialMGMT
}


function start-identification($result) {
    if ($result -eq $true){
        try {
            Write-Host "`nFound $ourMap already exists, Deleting...`n"
            net use $OurMap /delete
            net use
            start-map
        }
        catch {
            Write-Warning "`nSomething happened while deleting $driveLett drive...Exiting`n"
            Write-Host $_
            Exit-PSHostProcess
        }
    }elseif (($result -eq $false) -or ($null -eq $result)){
        Write-Host Write-Host "`nThere is no existing $ourMap drive, mapping now...`n"
        start-map
    }
}


try {
    $ErrorActionPreference = SilentlyContinue
    $logic = $findMaps.contains($ourMap)
}
catch {
    Write-Host "`nDrive is null...continuing`n"
    start-identification($result=$null)
}

if ($logic -eq $true){
    start-identification($result=$true)
}elseif($logic -eq $false){
    start-identification($result=$false)
}

