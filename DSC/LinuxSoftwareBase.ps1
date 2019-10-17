Configuration LinuxSoftwareBasev1
{

    Import-DSCResource -Module nx

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

        nxFileLine DoNotRequireTTY
        {
            FilePath = "/etc/nagios/nrpe.cfg"
            ContainsLine = 'allowed_hosts=127.0.0.1,161.131.194.38,::1'
            DoesNotContainPattern = "allowed_hosts=127.0.0.1,::1"
        }

    }
}

#config de ejemplo https://azurestack.blog/2016/02/adding-and-using-the-dsc-for-linux-vm-extension-to-azure-stack-tp1/
#como instalar epel https://www.shellhacks.com/epel-repo-centos-7-6-install/