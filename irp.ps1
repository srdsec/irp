<#
.Synopsis
   Created to assist Incident Response information gathering.

.DESCRIPTION
   Menu driven AD query tool.  Currently supports user or computer lookups. Must be
   run with permissions to current domain (standard user).  Requires the installation 
   of Server Remote Administration Tool Kit and the execution of 'Import-Module ActiveDirectory'

.PARAMETER None
   None

.EXAMPLE
   .\suiss-ir-adsearch.ps1

.LINK
    https://blogs.msdn.microsoft.com/rkramesh/2012/01/17/how-to-add-active-directory-module-in-powershell-in-windows-7/

.NOTES
   Version: 1.2 
   Last Updated: 6-April-2018. 
   Author: Shane Daniels, no rights reserved.
   Legal: Public domain, script provided "AS IS" without any warranties or
   guarantees whatsoever, use at your own risk, no tech support provided.
#>


# Menu
function Show-Menu
{
     param (
           [string]$Title = 'AD Query Script'
     )
     cls
     Write-Host "
     
    ____           _     __           __     ____                                           ____                         
   /  _/___  _____(_)___/ /__  ____  / /_   / __ \___  _________  ____  ____  ________     / __ \____ _      _____  _____
   / // __ \/ ___/ / __  / _ \/ __ \/ __/  / /_/ / _ \/ ___/ __ \/ __ \/ __ \/ ___/ _ \   / /_/ / __ \ | /| / / _ \/ ___/
 _/ // / / / /__/ / /_/ /  __/ / / / /_   / _, _/  __(__  ) /_/ / /_/ / / / (__  )  __/  / ____/ /_/ / |/ |/ /  __/ /    
/___/_/ /_/\___/_/\__,_/\___/_/ /_/\__/  /_/ |_|\___/____/ .___/\____/_/ /_/____/\___/  /_/    \____/|__/|__/\___/_/     
                                                        /_/                                                              
    

Author:       Shane Daniels
Script:       irp.ps1
Version:      1.2
Date:         04/06/18
Description:  Menu driven AD query tool.  Currently supports user or computer lookups. Must be
              run with permissions to current domain (standard user).  Requires the installation 
              of Server Remote Administration Tool Kit and the execution of 'Import-Module ActiveDirectory'

"

     Write-Host "================ $Title ================"
     Write-Host ""    
     Write-Host "1: Press '1' for to query AD for a user account."
     Write-Host "2: Press '2' for to query AD for a computer account."
     Write-Host "3: Press '3' for to query AD for a AD Group members."
     Write-Host "4: Press '4' for to reset AD password for user account."
     Write-Host "Q: Press 'Q' to quit."
     Write-Host ""
     Write-Host ""
}

# Action Loop
do
{
     Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input)
     {
           '1' {
                cls
                'You chose option #1'
                $queryuser = Read-Host -Prompt "Please Enter the UserName you want to search"
                Get-ADUser -Identity $queryuser -Properties * | select DisplayName,Created,EmailAddress,Title,Department,Manager,Office,OfficePhone,PrimaryGroup,MemberOf,LastLogonDate,LastBadPasswordAttempt,PasswordLastSet,PasswordExpired,PasswordNotRequired,PasswordNeverExpires
                Get-ADPrincipalGroupMembership $queryuser | select name | sort name | Format-Table
           } '2' {
                cls
                'You chose option #2'
                $querypc = Read-Host -Prompt "Please Enter the HostName you want to search"
                Get-ADComputer -Identity $querypc -Properties * | Format-List
           } '3' {
                cls
                'You chose option #3'
                $querygroup = Read-Host -Prompt "Please Enter the AD GroupName you want to search"
                Get-ADGroupMember -Identity $querygroup -Recursive | Format-List
           } '4' {
                cls
                'You chose option #4'
                $resetuser = Read-Host -Prompt "Please Enter the AD UserName for password reset"
                
                # Random password generator function, credit (http://activedirectoryfaq.com/2017/08/creating-individual-random-passwords/)

                function Get-RandomCharacters($length, $characters) {
                    $random = 1..$length | ForEach-Object { Get-Random -Maximum $characters.length }
                    $private:ofs=""
                    return [String]$characters[$random]
                }
 
                function Scramble-String([string]$inputString){     
                    $characterArray = $inputString.ToCharArray()   
                    $scrambledStringArray = $characterArray | Get-Random -Count $characterArray.Length     
                    $outputString = -join $scrambledStringArray
                    return $outputString 
                   }
 
                $password = Get-RandomCharacters -length 10 -characters 'abcdefghiklmnoprstuvwxyz'
                $password += Get-RandomCharacters -length 5 -characters 'ABCDEFGHKLMNOPRSTUVWXYZ'
                $password += Get-RandomCharacters -length 5 -characters '1234567890'
                $password += Get-RandomCharacters -length 5 -characters '!"$%&@#*+'
 
                #Write-Host $password
 
                $resetpass = Scramble-String $password
 
                Write-Host $resetpass

                #Set-ADAccountPassword -Reset -NewPassword $resetpass –Identity $resetuser

                Write-Host "Password for" $resetuser "reset successfully."

           } 'q' {
                return
           } default {
                cls
                'Invalid entry!'
            }

     }
     pause
}
until ($input -eq 'q')


