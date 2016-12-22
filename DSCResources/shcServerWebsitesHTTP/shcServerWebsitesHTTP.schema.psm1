Configuration shcServerWebsitesHTTP
{
    param(
      [Parameter()]$SiteNames,
      [Parameter()]$SiteType
    )
      
    Import-DscResource -ModuleName xRobocopy
    Import-DscResource -ModuleName xWebAdministration
      
    ForEach ($Site in $SiteNames)
    {
    Switch ($SiteType)
      {
        "dev" {$BindingName = "$Site-dev.shccs.com";$RepoFolder = "WebsitesDEV"}
        "qa" {$BindingName = "$Site-qa.shccs.com";$RepoFolder = "WebsitesQA"}
        "uat" {$BindingName = "$Site-uat.shccs.com";$RepoFolder = "WebsitesUAT"}
        "prod" {$BindingName = "$Site.shccs.com";$RepoFolder = "WebsitesPROD"}
      }

     File "$Site.shccs.com_Folder"
      {
        DestinationPath = "C:\Websites\$Site.shccs.com"
        Type            = "Directory"
      }
   
      xRobocopy "$Site.shccs.com_content"
      {
        Source                = "\\shccs.com\deployment\DSC\$RepoFolder\$Site.shccs.com"
        Destination           = "C:\Websites\$Site.shccs.com"
        Multithreaded         = $true
        Restartable           = $true
        AdditionalArgs        = "/MIR"
        #DependsOn             = "[File]$Site.shccs.com_folder"
      }

      xWebAppPool "$Site.shccs.com_pool"
      {
        Ensure                = "Present"
        Name                  = "$Site.shccs.com"
        State                 = "Started"
        AutoStart             = "True"
        ManagedPipelineMode   = "Integrated"
        ManagedRuntimeVersion = "v4.0"
        IdentityType          = "ApplicationPoolIdentity"
        Enable32BitAppOnWin64 = "False"
        RestartSchedule       = @("02:00:00")
        IdleTimeout           = "00:00:00"
        RestartTimeLimit      = "00:00:00"
        DependsOn             = "[File]$Site.shccs.com_folder"
      }

      xWebsite "$Site.shccs.com_website"
      { 
        Ensure          = "Present" 
        Name            = "$Site.shccs.com" 
        State           = "Started" 
        ApplicationPool = "$Site.shccs.com"
        PhysicalPath    = "C:\websites\$Site.shccs.com"  
        BindingInfo     = MSFT_xWebBindingInformation 
                          { 
                            Protocol = "HTTP" 
                            Port     =  80
                            HostName = "$BindingName"
                          } 
        DependsOn       = "[xWebAppPool]$Site.shccs.com_pool" 
      } 
    }
}