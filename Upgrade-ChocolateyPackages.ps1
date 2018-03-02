function Get-Versions ($versions) {
  $versions.Split('.') | ForEach-Object { [System.Convert]::ToInt32($_) }
}

function Parse-Packages($list) {
  $list | ForEach-Object {
    if (-not ($_ -match '^(?<name>[^\|]+)\|(?<old>[^\|]+)\|(?<new>[^\|]+)\|(?<pinned>[^\|]+)$')) {
      return $null
    }
    @{
      name = $matches['name']; 
      old  = @{versions = Get-Versions($matches['old'])}; 
      new  = @{versions = Get-Versions($matches['new'])};
      pinned = $matches['pinned']
    }
  }
}

function Select-UpgradablePackages($list) {
  $list | Where-Object {
    $oldVersions=$_['old']['versions'];
    $newVersions=$_['new']['versions'];
    return (($oldVersions[0] -lt $newVersions[0]) -or ($oldVersions[1] -lt $newVersions[1]))
  }
}

function Select-ChocolateyUpgradeCommands($names) {
  $names | ForEach-Object {
    "$env:CHOCOLATEY_UPGRADE -y $_"
  }
}

function Upgrade-ChocolateyPackages {
  $env:CHOCOLATEY_UPGRADE='cup';
  $list=Invoke-Expression "$env:CHOCOLATEY_UPGRADE --whatif -r all";
  $parsed=Parse-Packages($list);
  $selected=Select-UpgradablePackages($parsed) | ForEach-Object {$_['name']};
  $commands=Select-ChocolateyUpgradeCommands($selected);
  $commands | ForEach-Object {
    Invoke-Expression "$_"
  }
  $env:CHOCOLATEY_UPGRADE=$null;
}
