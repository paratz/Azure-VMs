Configuration FileResourceDemo
{
    Node "Localhost"
    {
        File CreateFile {
            DestinationPath = 'C:\Test.txt'
            Ensure = 'Present'
            Contents = 'Hola Mundo!'

        }
    }
}