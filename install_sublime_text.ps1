[CmdletBinding()]
param(
    [int]$st = ${env:SUBLIME_TEXT_VERSION}
)


try{
    if (-not $st) {
        throw "Missing Sublime Text version"
    }

    $url = $null
    foreach ( $link in (Invoke-WebRequest "http://www.sublimetext.com/$st" -UseBasicParsing).Links ) {
        if ( $link.href.endsWith("x64.zip") ) {
           $url = $link.href
           break
        }
    }
    if (-not $url) {
        throw "could not download Sublime Text binary"
    }

    $url = [System.Uri]::EscapeUriString($url)
    $filename = Split-Path $url -leaf

    write-verbose "installing sublime text ${env:SUBLIME_TEXT_VERSION}"
    (New-Object System.Net.WebClient).DownloadFile($url, "${env:Temp}\$filename")

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory("${env:Temp}\$filename", "C:\st")

    New-Item -itemtype directory "C:\st\Data\Packages\User" -force >$null
    "{`"update_check`": false }" | Out-File -filepath "C:\st\Data\Packages\User\Preferences.sublime-settings" -encoding ascii

}catch {
    throw $_
}
