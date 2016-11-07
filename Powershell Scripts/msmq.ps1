[Reflection.Assembly]::LoadWithPartialName("System.Messaging")
[System.Messaging.MessageQueue]::GetPrivateQueuesByMachine("itn-fortij") | % {".\" + $_.QueueName} | % {[System.Messaging.MessageQueue]::Delete($_); }

replace the second line with this one to only delete queues by some name
[System.Messaging.MessageQueue]::GetPrivateQueuesByMachine("itn-fortij") | % {".\" + $_.QueueName} | ? {$_ -match "SOME_REGEX_FILTER"} | % {[System.Messaging.MessageQueue]::Delete($_); }


function Get-PrivateQueuesByMachine
{ 
    [CmdletBinding()]
    Param(
        [Parameter(AttributeValues)]
        [string]
        $machineName = $env:COMPUTERNAME
    )
    process
    {
        gwmi -class Win32_PerfRawData_MSMQ_MSMQQueue -computerName $machineName | select Name, MessagesInQueue
    }
}

function Purge_Queue
{
    [CmdletBinding()]
    Param(
        [Parameter()]
        [string] $machineName = $env:COMPUTERNAME,
        [Parameter(Mandatory=$false)]
        [string] $QueueName
    )
    process
    {
        
    }
}