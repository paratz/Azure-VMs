﻿Configuration SoftwareDeBasev10
{

    Import-DscResource -ModuleName xDSCDomainjoin
    Import-DscResource -ModuleName PSDesiredStateConfiguration    
    $Cred = Get-AutomationPSCredential 'DomainCredentials'
    
Node localhost
{
        xDSCDomainjoin JoinDomain
            {
                Domain = 'dominio.com'
                Credential = $Cred
            }

    Package InstallNSClientv1
    {
        Ensure = "Present"
        Name = "NSClient++ (x64)"
        Path = "https://paratz.blob.core.windows.net/pubparatz/NSClient++-Stable-64.msi"
        Arguments = "ALLOWED_HOSTS=192.168.1.1 NSCLIENT_PWD=Password123 CONF_CHECKS=1 CONF_NSCLIENT=1 CONF_NRPE=1 CONF_NSCA=1"
        ProductId = "07C65535-76EB-43F7-8D88-C841E1FA2F8A"
    }

     Service NSClientServiceStart
        {
            Name        = "nsclientpp.exe"
            StartupType = "Automatic"
            State       = "Running"
        }

}
}