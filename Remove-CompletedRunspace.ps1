function Remove-CompletedRunspace
{
    [CmdletBinding()]
    param
    (
        [System.Collections.Specialized.OrderedDictionary] $AsyncObject,
        [int] $MaxRunTime = 15
    )

    if ($AsyncObject.Count -gt 0)
    {
        for ($i = 0; $i -lt $AsyncObject.Count; $i++)
        {
            $endTime = $AsyncObject[$i].StartTime.AddMinutes($MaxRunTime)
            $now = Get-Date

            #if ($AsyncObject[$i].State.IsCompleted -or $now.CompareTo($endTime))
            if ($AsyncObject[$i].State.IsCompleted -or ($now.CompareTo($endTime) -eq $true))
            {
                if ($AsyncObject[$i].State.IsCompleted)
                {
                    Write-Verbose "Runspace completed, removing task"
                }

                if ($now.CompareTo($endTime) -eq $true)
                {
                    Write-Verbose "Maximum runtime limit exceeded, this job may have failed. Removing task. Will output any info from stream."
                }

                if ($AsyncObject[$i].Powershell.Streams.Error.Count -gt 0)
                {                    
                    Write-Error "An error occured within your task"
                    Write-Verbose $AsyncObject[$i].Powershell.Streams.Error
                }

                Write-Output $AsyncObject[$i].Powershell.Streams.Information

                $AsyncObject[$i].Powershell.Dispose()
                #$threadResponse = $AsyncObject[$i].Powershell.EndInvoke($AsyncObject[$i].State) # if exception is thrown this kills session
                #Write-Verbose $threadResponse.ToString()
                #Write-Verbose $AsyncObject[$i].Powershell.Streams.Verbose
                $AsyncObject.Remove($AsyncObject[$i].Powershell.InstanceId.Guid)
            }
        }
    }
}