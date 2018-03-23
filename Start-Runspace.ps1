function Start-RunSpace
{
    param
    (
        [System.Collections.Specialized.OrderedDictionary] $AsyncObject,
        [System.Management.Automation.Runspaces.RunspacePool] $RunspacePool,
        [String] $BackgroundScript,
        [String] $ScriptArg
    )

    $powerShell = [powershell]::Create()
    $powerShell.RunspacePool = $runspacePool   

    [void] $powerShell.AddCommand(
        
        $BackgroundScript        
    )

    [void] $PowerShell.AddArgument($ScriptArg)

    $startTime = Get-Date
    $AsyncObject.Add($powerShell.InstanceId.Guid, @{State = $powerShell.BeginInvoke(); Powershell = $powerShell; StartTime = $startTime})
}