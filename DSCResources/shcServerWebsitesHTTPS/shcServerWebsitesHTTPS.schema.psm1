Configuration shcServerWebsitesHTTPS
{
    param(
      [Parameter()]$SiteNames,
      [Parameter()]$CertThumbprint,
      [Parameter()] $PfxPassword
    )
  
    Import-DscResource -ModuleName xRobocopy
    Import-DscResource -ModuleName xWebAdministration
    Import-DscResource -ModuleName xCertificate
      
    ForEach ($Site in $SiteNames)
    {
     File "$Site.shccs.com_Folder_HTTPS"
      {
        DestinationPath = "C:\Websites\$Site.shccs.com"
        Type            = "Directory"
      }
   
      xRobocopy "$Site.shccs.com_content_HTTPS"
      {
        Source                = "\\shccs.com\deployment\DSC\WebsitesPROD\$Site.shccs.com"
        Destination           = "C:\Websites\$Site.shccs.com"
        Multithreaded         = $true
        Restartable           = $true
        AdditionalArgs        = "/MIR"
        DependsOn             = "[File]$Site.shccs.com_folder_HTTPS"
      }

      xWebAppPool "$Site.shccs.com_pool_HTTPS"
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
        DependsOn             = "[File]$Site.shccs.com_folder_HTTPS"
      }

      xPfxImport wildcardCertImport
      {                      
        Path        = "C:\Certificates\shccs_com_wildcard_2016.pfx"
        Store       = "WebHosting"
        Thumbprint  = $CertThumbprint
        Credential  = $PfxPassword
      }

      xWebsite "$Site.shccs.com_website_HTTPS"
      { 
        Ensure          = "Present" 
        Name            = "$Site.shccs.com" 
        State           = "Started" 
        ApplicationPool = "$Site.shccs.com"
        PhysicalPath    = "C:\websites\$Site.shccs.com"  
        BindingInfo     = MSFT_xWebBindingInformation 
                          { 
                            Protocol = "HTTPS" 
                            Port     = 443
                            HostName = "$Site.shccs.com"
                            CertificateStoreName = "WebHosting"  
                            CertificateThumbprint = $CertThumbprint   
                          } 
        DependsOn       = "[xWebAppPool]$Site.shccs.com_pool_HTTPS" 
      } 
    }
}