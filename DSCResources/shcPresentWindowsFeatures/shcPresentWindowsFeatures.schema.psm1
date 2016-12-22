Configuration shcPresentWindowsFeatures
{
    param([Parameter()]$PresentFeatureName)
    
    ForEach ($pfn in $PresentFeatureName)
    {
        WindowsFeature $pfn
        {
            Name   = $pfn
            Ensure = "Present"
        }
    }
}