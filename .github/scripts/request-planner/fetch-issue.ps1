# NEW FILE - reads one GitHub issue (opening post, comments, positive reactions) and starts the
# Request Planner agent through trigger.ps1. Runs on PowerShell 7 (GitHub runner) or Windows PowerShell.
# Local test:  ./fetch-issue.ps1 -Repo WindowTop/WindowTop-App -IssueNumber 498 -DryRun
param(
    [Parameter(Mandatory)][string]$Repo,            # owner/name
    [Parameter(Mandatory)][string]$IssueNumber,
    [string]$Token = $env:GH_TOKEN,                 # optional locally (60 requests/hour without it)
    [string]$Maintainers = $env:PLANNER_MAINTAINERS, # comma-separated GitHub logins counted as maintainers
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
# Locally, reuse the GitHub CLI login if there is one. The token is needed for the opening post's
# "last edited" time; without it Thread state would differ from workflow runs (edited=-) and
# cause a needless SYNCED on the next workflow run.
if (-not $Token -and (Get-Command gh -ErrorAction SilentlyContinue)) { $Token = (& gh auth token 2>$null) }
if (-not $Token) { Write-Warning 'No GitHub token: opening-post edit time is unknown, Thread state may differ from workflow runs.' }
if ($IssueNumber -notmatch '^\d{1,7}$')      { throw "Invalid issue number '$IssueNumber'." }
if ($Repo -notmatch '^[\w.-]+/[\w.-]+$')     { throw "Invalid repository '$Repo'." }

$headers = @{ Accept = 'application/vnd.github+json'; 'X-GitHub-Api-Version' = '2022-11-28'; 'User-Agent' = 'windowtop-request-planner' }
if ($Token) { $headers.Authorization = "Bearer $Token" }
$api = "https://api.github.com/repos/$Repo"

function Get-AllPages([string]$Uri) {
    $items = @()
    while ($Uri) {
        $resp = Invoke-WebRequest -Uri $Uri -Headers $headers -UseBasicParsing
        $items += @($resp.Content | ConvertFrom-Json)
        $Uri = $null
        $link = [string]($resp.Headers['Link'] | Select-Object -First 1)
        if ($link -match '<([^>]+)>;\s*rel="next"') { $Uri = $Matches[1] }
    }
    return $items
}

$maintainerLogins = @($Maintainers -split ',' | ForEach-Object { $_.Trim().ToLowerInvariant() } | Where-Object { $_ })
function Test-Maintainer([string]$Login, [string]$Association) {
    return ($Association -in 'OWNER', 'MEMBER', 'COLLABORATOR') -or ($maintainerLogins -contains $Login.ToLowerInvariant())
}

$issue = Invoke-RestMethod -Uri "$api/issues/$IssueNumber" -Headers $headers
if ($issue.pull_request) { throw "#$IssueNumber is a pull request, not an issue." }
$opLogin = [string]$issue.user.login

$thread = @(foreach ($c in (Get-AllPages "$api/issues/$IssueNumber/comments?per_page=100")) {
    if ($c.user.type -eq 'Bot') { continue }
    [ordered]@{
        id               = [string]$c.id
        author           = [string]$c.user.login
        isOriginalPoster = ([string]$c.user.login -eq $opLogin)
        isMaintainer     = (Test-Maintainer ([string]$c.user.login) ([string]$c.author_association))
        createdAt        = [string]$c.created_at
        editedAt         = $(if ($c.updated_at -ne $c.created_at) { [string]$c.updated_at } else { '' })
        body             = [string]$c.body
    }
})

# Positive reactions on the opening post, excluding bots and maintainers.
$positive = '+1', 'heart', 'hooray', 'rocket'
$reactionUsers = @(Get-AllPages "$api/issues/$IssueNumber/reactions?per_page=100" |
    Where-Object { $_.content -in $positive -and $_.user.type -ne 'Bot' -and -not (Test-Maintainer ([string]$_.user.login) '') } |
    ForEach-Object { [string]$_.user.login } | Sort-Object -Unique)

# The REST API has no "edited at" for the opening post, GraphQL does (needs a token).
$postEditedAt = ''
if ($Token) {
    $owner, $name = $Repo.Split('/')
    $query = @{
        query     = 'query($o:String!,$n:String!,$i:Int!){repository(owner:$o,name:$n){issue(number:$i){lastEditedAt}}}'
        variables = @{ o = $owner; n = $name; i = [int]$IssueNumber }
    } | ConvertTo-Json -Depth 4
    try {
        $g = Invoke-RestMethod -Method Post -Uri 'https://api.github.com/graphql' -Headers $headers -Body $query -ContentType 'application/json'
        $postEditedAt = [string]$g.data.repository.issue.lastEditedAt
    } catch { Write-Warning "lastEditedAt unavailable: $($_.Exception.Message)" }
}

$threadFile = Join-Path ([IO.Path]::GetTempPath()) "request-planner-thread-$IssueNumber.json"
ConvertTo-Json -InputObject @($thread) -Depth 4 | Set-Content -LiteralPath $threadFile -Encoding UTF8

$planner = @{
    Source        = 'github'
    Url           = [string]$issue.html_url
    Title         = [string]$issue.title
    Body          = [string]$issue.body
    Author        = $opLogin
    ThreadFile    = $threadFile
    PostEditedAt  = $postEditedAt
    ReactionUsers = $reactionUsers
}
if ($DryRun) { $planner.DryRun = $true }

$output = & "$PSScriptRoot/trigger.ps1" @planner
$output
if ($env:GITHUB_STEP_SUMMARY -and -not $DryRun) {
    Add-Content -LiteralPath $env:GITHUB_STEP_SUMMARY -Value ("### Request Planner started`n`n" + (($output | ForEach-Object { "- $_" }) -join "`n"))
}
