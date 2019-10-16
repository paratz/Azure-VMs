Configuration LinuxSoftwareBasev1
{

    Import-DSCResource -Module nx

    Node localhost
    {
        nxPackage epel-release 
        {
            Name = "epel-release"
            Ensure = "Present"
            PackageManager = "Yum"
        }
    

        nxPackage nrpe
        {
            Name = "nrpe"
            Ensure = "Present"
            PackageManager = "Yum"
        }

}
}