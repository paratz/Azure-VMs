Configuration LinuxSoftwareBasev1
{

    Import-DSCResource -Module nx
    Import-DscResource -Module LinuxResourcesDSC

    Node localhost
    {
        nxPackage epel-release 
        {
            Name = "epel-release-latest-7.noarch.rpm"
            Ensure = "Present"
            FilePath = "https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm"
            PackageManager = "Yum"
        }
    
        nxPackage nrpe
        {
            Name = "nrpe"
            Ensure = "Present"
            PackageManager = "Yum"
            DependsOn = '[nxPackage]epel-release'
        }

        nxFileContent ConfiguraAllowedHosts
        {
            TestCommand = "pass"
            Name = "ConfigureAllowedHosts"
            FileName = "/etc/nagios/nrpe.cfg"
            FileContent = 'allowed_hosts=127.0.0.1,192.168.1.1,::1'
            EditRegex = 'allowed_hosts=127.0.0.1,::1'
            DependsOn = '[nxPackage]nrpe'
        }

    }
}

#config de ejemplo https://azurestack.blog/2016/02/adding-and-using-the-dsc-for-linux-vm-extension-to-azure-stack-tp1/
#como instalar epel https://www.shellhacks.com/epel-repo-centos-7-6-install/