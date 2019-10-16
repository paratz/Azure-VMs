Configuration LinuxSoftwareBasev1
{

Import-DSCResource -Module nx

Node localhost
{
    nxPackage nrpe
    {
        Name = "nrpe"
        Ensure = "Present"
        PackageManager = "Yum"
    }
}


}