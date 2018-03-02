# This can be run using Invoke-Pester in PowerShell V3 or newer

## PowerShell v2-compatible import
#$here = (Split-Path -Parent $MyInvocation.MyCommand.Path)
#. $here\Set-Env.ps1

# PowerShell v3-compatible import
. $PSScriptRoot\Upgrade-ChocolateyPackages.ps1

$testData="clojure|1.5.0|1.6.0|false
clojure.clr|1.3.0|1.3.0|false
boot-clj|2.6.1|2.6.2|false
love.install|0.9.2|0.10.2|true".Split([Environment]::NewLine);

Describe "Parse-Packages" {
  It "Provides an array of hash tables mapping each package's properties to values." {
    $actual=Parse-Packages($testData);
    $expected=@(
      @{name="clojure";old=@("1","5","0");new=@("1","6","0");pinned="false"},
      @{name="clojure.clr";old=@("1","3","0");new=@("1","3","0");pinned="false"},
      @{name="boot-clj";old=@("2","6","1");new=@("2","6","2");pinned="false"},
      @{name="love.install";old=@("0","9","2");new=@("0","10","2");pinned="true"}
    )
    (Compare-Object $actual $expected).InputObject | Should -BeNullOrEmpty # a bit of a hack, in order to deeply compare collections
  }
}

Describe "Select-UpgradablePackages" {
  It "Provides only the hash tables representing the packages whose new major or minor versions are greater than those of their old versions. Pinned flag is not respected (yet)." {
    $packages=Parse-Packages($testData)
    $actual=Select-UpgradablePackages($packages);
    $expected=@(
      @{name="clojure";old=@("1","5","0");new=@("1","6","0");pinned="false"},
      @{name="love.install";old=@("0","9","2");new=@("0","10","2");pinned="true"}
    )
    (Compare-Object $actual $expected).InputObject | Should -BeNullOrEmpty
  }
}
