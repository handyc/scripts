[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") 

Function Get-Folder($initialDirectory, $desc) {
    [void] [System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')
    $FolderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
     $FolderBrowserDialog.Description = $desc;
    $FolderBrowserDialog.RootFolder = 'MyComputer'
    if ($initialDirectory) { $FolderBrowserDialog.SelectedPath = $initialDirectory }
    #[void] $FolderBrowserDialog.ShowDialog()
    $Result = $FolderBrowserDialog.ShowDialog()
 If ($Result -eq [System.Windows.Forms.DialogResult]::Cancel) {
Write-Host "aborted!"
Exit
} 

    return $FolderBrowserDialog.SelectedPath
}

$sourcedir = Get-Folder C:\Users "Choose the source folder"
$destdir = Get-Folder C:\Users "Choose the destination folder"

New-Item -ItemType Directory -Force -Path $destdir

Write-Host "getting files from" $sourcedir 
$files = Get-ChildItem $sourcedir

Write-Host "copying files from " $sourcedir " to " $destdir 

for ($i=0; $i -lt $files.Count; $i++) {
$fullpath = $files[$i].FullName
$filename = $files[$i].BaseName
$firstletter = $filename.Substring(0,1)

New-Item -ItemType Directory -Force -Path $destdir\$firstletter
Copy-Item -Path $fullpath -Destination $destdir\$firstletter
}

Write-Host "finished copying files from " $sourcedir " to " $destdir 
Write-Host "enjoy your new copied library!" 
