$SubscriptionId = "4d55c914-726b-4a03-b002-54c4bf217ad5"
$ResourceGroupName = "avd-rg"
$StorageAccountName = "storagenncd2d"
$SamAccountName = "storagenncd2d"
$DomainAccountType = "ComputerAccount" # Default is set as ComputerAccount
# Specify the encryption algorithm used for Kerberos authentication. Using AES256 is recommended.
$EncryptionType = "AES256"


# Change the execution policy to unblock importing AzFilesHybrid.psm1 module
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

# Navigate to where AzFilesHybrid is unzipped and stored and run to copy the files into your path
.\CopyToPSPath.ps1 

# Import AzFilesHybrid module
Import-Module -Name AzFilesHybrid

#Install-Module -Name Az.Accounts
Install-Module -Name Az.Accounts

# Login to Azure using a credential that has either storage account owner or contributor Azure role 
# assignment. If you are logging into an Azure environment other than Public (ex. AzureUSGovernment) 
# you will need to specify that.
# See https://learn.microsoft.com/azure/azure-government/documentation-government-get-started-connect-with-ps
# for more information.
Connect-AzAccount

# Select the target subscription for the current session
Select-AzSubscription -SubscriptionId $SubscriptionId 

Join-AzStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -StorageAccountName $StorageAccountName `
        -SamAccountName $SamAccountName `
        -DomainAccountType $DomainAccountType `
        -EncryptionType $EncryptionType

Debug-AzStorageAccountAuth -StorageAccountName $StorageAccountName -ResourceGroupName $ResourceGroupName -Verbose


# Get the target storage account
$storageaccount = Get-AzStorageAccount `
        -ResourceGroupName $ResourceGroupName `
        -Name $StorageAccountName

# List the directory service of the selected service account
$storageAccount.AzureFilesIdentityBasedAuth.DirectoryServiceOptions

# List the directory domain information if the storage account has enabled AD DS authentication for file shares
$storageAccount.AzureFilesIdentityBasedAuth.ActiveDirectoryProperties


# mount azure files on any domain-joined machine
net use Z: \\storagenncd2d.file.core.windows.net\fslogix oWW4+HTIOEf+BWm1EuCBLPk9I5TNhck0oEI6ZSEzwpL9HShVoXZQB+jnTVrkLc8J9yl7ceg/UghF+AStLSXrrw== /user:Azure\storagenncd2d

# assign permissions to the mounted drive
icacls Z: /grant "INFRA\TestAVDUserGroup:(M)"
icacls Z: /grant "Creator Owner:(OI)(CI)(IO)(M)"
icacls Z: /remove "Authenticated Users"
icacls Z: /remove "Builtin\Users"
