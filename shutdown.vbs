On Error Resume Next

Do While True
    currentHour = Hour(Now)
    currentMinute = Minute(Now)
    currentSecond = Second(Now)
    
    If currentHour >= 1 And currentHour <= 5 Then
        firstCPUUsage = GetCPUUsage()
        ' Pause for 20 second before getting CPU usage data for 2nd time
        WScript.Sleep 20000
        secondCPUUsage = GetCPUUsage()

        If firstCPUUsage < 10 And secondCPUUsage < 10 Then
            ' Pause for 100 second before shutting down
            WScript.Sleep 100000
            ShutdownComputer()
        End If
    End If
    
    ' Pause for 10 second before checking again
    WScript.Sleep 10000
Loop

Function GetCPUUsage()
    Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")
    Set colItems = objWMIService.ExecQuery("Select * from Win32_PerfFormattedData_PerfOS_Processor Where Name = '_Total'")

    For Each objItem in colItems
        cpuUsage = objItem.PercentProcessorTime
    Next
    
    GetCPUUsage = cpuUsage
End Function

Sub ShutdownComputer()
    Set objShell = CreateObject("WScript.Shell")
    objShell.Run "shutdown /s /t 0", 0, True
End Sub
