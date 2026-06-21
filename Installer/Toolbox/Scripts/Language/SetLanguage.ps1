param (
    [Parameter(Mandatory)]
    [string]$Lang,
    [Parameter(Mandatory)]
    [int]$GeoId
)

$ErrorActionPreference = 'Stop'

Write-Output "Installing language pack for $Lang (if not already installed)..."
$installed = Get-InstalledLanguage -Language $Lang -ErrorAction SilentlyContinue
if (-not $installed) {
    Install-Language -Language $Lang
}

Write-Output "Setting Windows UI language to $Lang..."
Set-SystemPreferredUILanguage -Language $Lang

Write-Output "Setting system locale, user language list and home location to $Lang..."
Set-WinSystemLocale -SystemLocale $Lang
Set-WinUserLanguageList -LanguageList $Lang -Force
Set-Culture -CultureInfo $Lang
Set-WinHomeLocation -GeoId $GeoId

Write-Output "Applying these settings to the welcome screen and new user accounts..."
Copy-UserInternationalSettingsToSystem -SourceUser Current -DestinationUser System, NewUser

Write-Output "Done. A restart is required for every change to fully apply."
