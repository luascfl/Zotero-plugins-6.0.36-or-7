#<
Unblock-File -Path .\Backup_Zotero_Plugins.ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
#>

# Release versions that only work in Zotero 6 Repository
Invoke-WebRequest -Uri "https://github.com/windingwind/zotero-pdf-translate/releases/download/v1.0.25/zotero-pdf-translate.xpi" -OutFile "$HOME\Downloads\zotero6-pdf-translate.xpi"
Invoke-WebRequest -Uri "https://github.com/syt2/zotero-addons/releases/download/0.6.0-6/zotero-addons.xpi" -OutFile "$HOME\Downloads\zotero6-addons.xpi"
Invoke-WebRequest -Uri "https://github.com/northword/zotero-format-metadata/releases/download/0.4.4/zotero-format-metadata-0.4.5.xpi" -OutFile "$HOME\Downloads\zotero6-format-metadata.xpi"
Invoke-WebRequest -Uri "https://github.com/Dominic-DallOsto/zotero-reading-list/releases/download/v0.3.2/zotero-reading-list-0.3.2.xpi" -OutFile "$HOME\Downloads\zotero6-reading-list.xpi"
Invoke-WebRequest -Uri "https://github.com/jlegewie/zotfile/releases/download/v5.1.2/zotfile-5.1.2-fx.xpi" -OutFile "$HOME\Downloads\zotero6-zotfile.xpi"
Invoke-WebRequest -Uri "https://github.com/MuiseDestiny/zotero-gpt/releases/download/0.3.0/zotero-gpt.xpi" -OutFile "$HOME\Downloads\zotero6-gpt.xpi"


# List of repository URLs
$repos = @(
    "https://github.com/UB-Mannheim/zotero-ocr/releases/latest",
    "https://github.com/windingwind/zotero-pdf-translate/releases/latest",
    "https://github.com/tefkah/zotero-night/releases/latest",
    "https://github.com/bwiernik/zotero-shortdoi/releases/latest",
    "https://github.com/syt2/zotero-addons/releases/latest",
    "https://github.com/northword/zotero-format-metadata/releases/latest",
    "https://github.com/Dominic-DallOsto/zotero-reading-list/releases/latest",
    "https://github.com/MuiseDestiny/zotero-gpt/releases/latest",
    "https://github.com/wbthomason/zotodo/releases/latest",
    "https://github.com/windingwind/zotero-pdf-preview/releases/latest",
    "https://github.com/iShareStuff/Backup-Plugin-for-Zotero/releases/latest",
    "https://github.com/ManuelaRunge/Zotitle/releases/latest"
)

function Get-LatestReleaseInfo {
    param (
        [string]$repoUrl
    )

    # Makes a request to the GitHub API to get the latest version of the repository
    $apiUrl = $repoUrl -replace "https://github.com/", "https://api.github.com/repos/" -replace "/releases/latest", "/releases/latest"
    $release = Invoke-RestMethod -Uri $apiUrl -Method Get -Headers @{ "User-Agent" = "PowerShell" }

    # Updates the download button for the .xpi file
    $asset = Update-DownloadButton -release $release -assetExtension ".xpi"

    # If the asset was found, downloads it
    if ($asset) {
        Download-File -url $asset.browser_download_url -destination "$HOME\Downloads\$($asset.name)"
    }
}

function Update-DownloadButton {
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$release,
        [Parameter(Mandatory = $true)]
        [string]$assetExtension
    )

    # Finds the asset matching the provided extension
    $asset = $release.assets | Where-Object { $_.name -like "*$assetExtension" }

    if ($asset) {
        # Gets version information
        $releaseInfo = "Version: $($release.tag_name.Substring(1))`n" +
                       "File size: $([math]::Round($asset.size / 1MB, 2)) MB`n" +
                       "Release date: $([datetime]::Parse($asset.updated_at).ToString("yyyy-MM-dd"))`n" +
                       "Download count: $($asset.download_count.ToString('N0'))"

        # Displays download information
        Write-Host "Download link for ${asset.name}: $($asset.browser_download_url)"
        Write-Host "Release Info: $releaseInfo"
        
        # Returns the found asset
        return $asset
    } else {
        Write-Host "No asset found for extension: $assetExtension"
        return $null
    }
}

function Download-File {
    param (
        [Parameter(Mandatory = $true)]
        [string]$url,
        [Parameter(Mandatory = $true)]
        [string]$destination
    )

    # Downloads the file and saves it to the specified destination
    try {
        Invoke-WebRequest -Uri $url -OutFile $destination
        Write-Host "File downloaded to: $destination"
    } catch {
        Write-Host "Failed to download file: $_"
    }
}

# Iterates over each repository in the list
foreach ($repo in $repos) {
    Write-Host "Processing repository: $repo"
    Get-LatestReleaseInfo -repoUrl $repo
}
