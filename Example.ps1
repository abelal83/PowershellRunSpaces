
Remove-Module -Name Runspace -Force

Import-Module "$PSScriptRoot\Runspace.psm1"

$_AsyncObject = New-Object System.Collections.Specialized.OrderedDictionary
$_RunspacePool = New-RunspacePool

$RunLotsOfTimesScript = "$PSScriptRoot\Example-BackgroundScript.ps1"

$SayHelloTo = @("Abs", "Dean", "Mark", "Ian")

foreach ($person in $SayHelloTo)
{
    if ($_RunspacePool.GetAvailableRunspaces() -eq 0)
    {
        Write-Host 'RunspacePool is full at the moment, may take a while to process this request'
    }

    Write-Output "Starting runspace with arg $person"
    Start-RunSpace -AsyncObject $_AsyncObject -RunspacePool $_RunspacePool -BackgroundScript $RunLotsOfTimesScript -ScriptArg $person

    Remove-CompletedRunspace $_AsyncObject -MaxRunTime 1 -Verbose
}

while ($_RunspacePool.GetAvailableRunspaces() -ne $_RunspacePool.GetMaxRunspaces())
{
    Remove-CompletedRunspace $_AsyncObject -MaxRunTime 1 -Verbose

    Start-Sleep -Seconds 3
}

Write-Host "completed"