Configuration shcAbsentWindowsFeatures
{
    param([Parameter()]$AbsentFeatureName)
    
    ForEach ($afn in $AbsentFeatureName)
    {
        WindowsFeature $afn
        {
            Name   = $afn
            Ensure = "Absent"
        }
    }
}