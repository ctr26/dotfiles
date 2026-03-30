# Managed by chezmoi
$env:EDITOR = "code"

if (Get-Command gh -ErrorAction SilentlyContinue) {
    Invoke-Expression -Command $(gh completion -s powershell | Out-String)
}

Set-Alias -Name g -Value git
