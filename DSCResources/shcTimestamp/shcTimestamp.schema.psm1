Configuration shcTimestamp {
  Param
  (
    [ValidateSet("Present","Absent")]
    [System.String]
    $Ensure
  )

  if ($Ensure -eq "Present")
  {
    Script LeaveTimestamp
    {
      SetScript = {
        $currentTime = Get-Date
        $currentTimeString = $currentTime.ToUniversalTime().ToString()
        [Environment]::SetEnvironmentVariable("DSCClientRun","Last DSC-Client run (UTC): $currentTimeString","Machine")
        eventcreate /t INFORMATION /ID 1 /L APPLICATION /SO "DSC-Client" /D "Last DSC-Client run (UTC): $currentTimeString"
      }
      TestScript = {
        $false
      }
      GetScript = {
        # Do Nothing
      }
    }
  }
}