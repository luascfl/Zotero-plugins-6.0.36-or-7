#<
Unblock-File -Path .\Backup_Zotero_Plugins.ps1
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
#>

function Download-LatestXpi {
    param (
        [string]$owner,
        [string]$repo,
        [string]$outputFile
    )
    $apiUrl = "https://api.github.com/repos/$owner/$repo/releases/latest"
    try {
        $release = Invoke-RestMethod -Uri $apiUrl -Headers @{ "User-Agent" = "PowerShell" }
        $asset = $release.assets | Where-Object { $_.name -like "*.xpi" } | Select-Object -First 1
        if ($asset) {
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "$HOME\Downloads\$outputFile"
            Write-Host "Downloaded $outputFile"
        } else {
            Write-Host "No .xpi asset found for $owner/$repo"
        }
    } catch {
        Write-Host ("Error downloading {0}: {1}" -f $outputFile, $_.Exception.Message)
    }
}

# 1. Release versions that work in Zotero 6 Repository
# Downloads com versões específicas
Invoke-WebRequest -Uri "https://github.com/windingwind/zotero-pdf-translate/releases/download/v1.0.25/zotero-pdf-translate.xpi" -OutFile "$HOME\Downloads\zotero6-pdf-translate.xpi"
Invoke-WebRequest -Uri "https://github.com/syt2/zotero-addons/releases/download/0.6.0-6/zotero-addons.xpi" -OutFile "$HOME\Downloads\zotero6-addons.xpi"
Invoke-WebRequest -Uri "https://github.com/northword/zotero-format-metadata/releases/download/0.4.4/zotero-format-metadata-0.4.5.xpi" -OutFile "$HOME\Downloads\zotero6-format-metadata.xpi"
Invoke-WebRequest -Uri "https://github.com/Dominic-DallOsto/zotero-reading-list/releases/download/v0.3.2/zotero-reading-list-0.3.2.xpi" -OutFile "$HOME\Downloads\zotero6-reading-list.xpi"
Invoke-WebRequest -Uri "https://github.com/jlegewie/zotfile/releases/download/v5.1.2/zotfile-5.1.2-fx.xpi" -OutFile "$HOME\Downloads\zotero6-zotfile.xpi"
Invoke-WebRequest -Uri "https://github.com/MuiseDestiny/zotero-gpt/releases/download/0.3.0/zotero-gpt.xpi" -OutFile "$HOME\Downloads\zotero6-gpt.xpi"
Invoke-WebRequest -Uri "https://github.com/lifan0127/ai-research-assistant/releases/download/0.8.0/aria.xpi" -OutFile "$HOME\Downloads\zotero6-aria.xpi"
Invoke-WebRequest -Uri "https://github.com/scitedotai/scite-zotero-plugin/releases/download/v1.11.6/zotero-scite-1.11.6.xpi" -OutFile "$HOME\Downloads\zotero6-scite.xpi"

# Downloads com versões latest usando API do GitHub
Download-LatestXpi -owner "ManuelaRunge" -repo "Zotitle" -outputFile "zotero6-zotitle.xpi"
Download-LatestXpi -owner "iShareStuff" -repo "Backup-Plugin-for-Zotero" -outputFile "zotero6-backupplugin.xpi"
Download-LatestXpi -owner "windingwind" -repo "zotero-pdf-preview" -outputFile "zotero6-pdfpreview.xpi"
Download-LatestXpi -owner "wbthomason" -repo "zotodo" -outputFile "zotero6-zotodo.xpi"
Download-LatestXpi -owner "tefkah" -repo "zotero-night" -outputFile "zotero6-night.xpi"
Download-LatestXpi -owner "ethanwillis" -repo "zotero-scihub" -outputFile "zotero6-scihub.xpi"

# 2. Release versions that work in Zotero 7
$repos = @(
    @{ Owner = "UB-Mannheim"; Repo = "zotero-ocr" },
    @{ Owner = "windingwind"; Repo = "zotero-pdf-translate" },
    @{ Owner = "bwiernik"; Repo = "zotero-shortdoi" },
    @{ Owner = "syt2"; Repo = "zotero-addons" },
    @{ Owner = "northword"; Repo = "zotero-format-metadata" },
    @{ Owner = "Dominic-DallOsto"; Repo = "zotero-reading-list" },
    @{ Owner = "MuiseDestiny"; Repo = "zotero-gpt" },
    @{ Owner = "lifan0127"; Repo = "ai-research-assistant" },
    @{ Owner = "papersgpt"; Repo = "papersgpt-for-zotero" },
    @{ Owner = "windingwind"; Repo = "bionic-for-zotero" },
    @{ Owner = "wileyyugioh"; Repo = "zotmoov" },
    @{ Owner = "ImperialSquid"; Repo = "zotero-zotts" },
    @{ Owner = "wshanks"; Repo = "zutilo" }
)

foreach ($repo in $repos) {
    $owner = $repo.Owner
    $repoName = $repo.Repo
    $apiUrl = "https://api.github.com/repos/$owner/$repoName/releases/latest"
    try {
        $release = Invoke-RestMethod -Uri $apiUrl -Headers @{ "User-Agent" = "PowerShell" }
        $asset = $release.assets | Where-Object { $_.name -like "*.xpi" } | Select-Object -First 1
        if ($asset) {
            $outputFile = $asset.name
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile "$HOME\Downloads\$outputFile"
            Write-Host "Downloaded $outputFile"
        } else {
            Write-Host "No .xpi asset found for $owner/$repoName"
        }
    } catch {
        Write-Host ("Error downloading from {0}/{1}: {2}" -f $owner, $repoName, $_.Exception.Message)
    }
}

# Movendo plugins para pasta especial
$starredPlugins = @(
    "zotero6-zotfile.xpi",
    "zotero6-zotitle.xpi",
    "zotero6-pdfpreview.xpi",
    "zotero6-reading-list.xpi",
    "zotero6-zotodo.xpi"
)

$starredFolder = "$HOME\Downloads\Starred plugins Zotero 6"
if (-not (Test-Path -Path $starredFolder)) {
    New-Item -ItemType Directory -Path $starredFolder
}

foreach ($plugin in $starredPlugins) {
    $sourcePath = "$HOME\Downloads\$plugin"
    if (Test-Path -Path $sourcePath) {
        Move-Item -Path $sourcePath -Destination $starredFolder
        Write-Host "Moved $plugin to $starredFolder"
    } else {
        Write-Host "$plugin not found in Downloads folder"
    }
}