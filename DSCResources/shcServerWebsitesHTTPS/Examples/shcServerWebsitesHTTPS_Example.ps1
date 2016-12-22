### Example configuration referencing the new composite resource
Configuration aaaaaa {
    
    Import-DscResource -ModuleName shcCompositeResources

    Node localhost {

        shcServerWebsitesHTTPS bbbbbb {
            property = value
        }

    }
}