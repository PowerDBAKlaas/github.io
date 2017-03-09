function Get-MyProfile {
  <#
    .SYNOPSIS
    Shows all profile files.

    .DESCRIPTION
    The four potential file locations for the profile are returned, together with an extra property for the files that really exist.
    
    The $PROFILE variable holds 4 filepaths, depending on the current user and the current host. That does not mean those files all exist.
    This function returns not only the provided paths, but also whether they really exist.

    .PARAMETER Edit
    When this switch is added, the existing profile files are opened with notepad.

    .EXAMPLE
    Get-MyProfile -Edit
    Shows what locations are provided for the four profile files for the current context, and the actual files for those that exist.
    The existing files are opened with notepad.

    .NOTES
    Author: Klaas Vandenberghe
    Date:   2017-03-09

    .INPUTS
    None

    .OUTPUTS
    PSCustomObject
    Files
  #>


  [CmdletBinding()]
  Param (
    [Switch]$Edit
  )

  if ($PSBoundParameters.ContainsKey('Edit'))
  {
    if ( Test-Path -Path $profile.AllUsersAllHosts ) { & "$env:windir\system32\notepad.exe" $profile.AllUsersAllHosts }
    if ( Test-Path -Path $profile.AllUsersCurrentHost ) { & "$env:windir\system32\notepad.exe" $profile.AllUsersCurrentHost }
    if ( Test-Path -Path $profile.CurrentUserAllHosts ) { & "$env:windir\system32\notepad.exe" $profile.CurrentUserAllHosts }
    if ( Test-Path -Path $profile.CurrentUserCurrentHost ) { & "$env:windir\system32\notepad.exe" $profile.CurrentUserCurrentHost } 
  }

  [PSCustomObject]@{
        AllUsersAllHosts = $profile.AllUsersAllHosts
        AllUsersCurrentHost = $profile.AllUsersCurrentHost
        CurrentUserAllHosts = $profile.CurrentUserAllHosts
        CurrentUserCurrentHost = $profile.CurrentUserCurrentHost
        AllUsersAllHostsFile = $(if ( Test-Path -Path $profile.AllUsersAllHosts ) { $profile.AllUsersAllHosts })
        AllUsersCurrentHostFile = $(if ( Test-Path -Path $profile.AllUsersCurrentHost ) { $profile.AllUsersCurrentHost })
        CurrentUserAllHostsFile = $(if ( Test-Path -Path $profile.CurrentUserAllHosts ) { $profile.CurrentUserAllHosts})
        CurrentUserCurrentHostFile = $(if ( Test-Path -Path $profile.CurrentUserCurrentHost ) { $profile.CurrentUserCurrentHost})
  }
}