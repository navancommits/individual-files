# Trigger
$atStartupeverySixtyMinutesTrigger = New-JobTrigger -once -At $(get-date) -RepetitionInterval $([timespan]::FromMinutes("60")) -RepeatIndefinitely

$scriptPath = 'C:\pstst\Content_Serialization_PS_Script.PS1'

Register-ScheduledJob -Name SitecoreContentSerializationScheduler -FilePath $scriptPath -Trigger $atStartupeverySixtyMinutesTrigger