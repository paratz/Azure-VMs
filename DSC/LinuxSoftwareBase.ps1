﻿Configuration LinuxSoftwareBasev1
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
        
        nxScript ConfiguraAllowedHosts {

                GetScript = @"
            #!/bin/bash
            grep -c "allowed_hosts=127.0.0.1,::1" /etc/nagios/nrpe.cfg
            "@

                SetScript = @"
            #!/bin/bash
            sed -i 's/allowed_hosts=127.0.0.1,::1/allowed_hosts=127.0.0.1,192.168.1.1,::1/' /etc/nagios/nrpe.cfg
            "@

                TestScript = @'
            #!/bin/bash
            linecount=`grep -c "allowed_hosts=127.0.0.1,::1" /etc/nagios/nrpe.cfg`
            if [ $linecount -eq 1 ]
            then
                exit 1
            else
                exit 0
            fi
            '@
                }
        

    }
}

#config de ejemplo https://azurestack.blog/2016/02/adding-and-using-the-dsc-for-linux-vm-extension-to-azure-stack-tp1/
#como instalar epel https://www.shellhacks.com/epel-repo-centos-7-6-install/
