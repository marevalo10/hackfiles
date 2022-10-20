<?php
$errors = []; // Store errors here
$fileExtensionsAllowed = ['jpeg','jpg','png']; // These will be the only file extensions allowed (if required)
$uploaddir = '/var/www/uploads/'; 
$uploadfile = $uploaddir . basename($_FILES['file']['name']);

$fileName = $_FILES['file']['name'];
$fileSize = $_FILES['file']['size'];
$fileTmpName  = $_FILES['file']['tmp_name'];
$fileType = $_FILES['file']['type'];
$fileExtension = strtolower(end(explode('.',$fileName)));
$uploadPath = $uploaddir . basename($fileName); 

echo '<pre>';
echo 'Received File: ' .  basename($fileName);
echo '<br>Temporary name: ' . $fileTmpName;
echo "Upload Path: " . $uploadPath;

#if (isset($_POST['submit'])) {
    #In case it is required to limit the extension
    #if (! in_array($fileExtension,$fileExtensionsAllowed)) {
    #    $errors[] = "This file extension is not allowed. Please upload a JPEG or PNG file";
    #}

    if ($fileSize > 4000000) {
        $errors[] = "File exceeds maximum size (4MB)";
    }

    if (empty($errors)) {
        $didUpload = move_uploaded_file($fileTmpName, $uploadPath);
        #If the files are not uploading, then the issue could be permissions in the upload directory. chmod -R 777 uploads
        #Another option
        #$didUpload = copy($fileTmpName, $uploadPath);

        if ($didUpload) {
            echo "The file " . basename($fileName) . " has been uploaded";
        } 
        else {
            echo "An error occurred. Please contact the administrator.";
        }
    } 
    else {
        foreach ($errors as $error) {
            echo $error . "These are the errors" . "\n";
        }
    }

#}


// Check if file was uploaded without errors
#if(isset($_FILES['file']) && $_FILES['file']['error'] == 0){
#    if (move_uploaded_file($_FILES['file']['tmp_name'], $uploadfile)) {
#        echo "File is valid, and was successfully uploaded.\n";
#    } 
#    else {
#        echo "Possible file upload issue!\n";
#    }
#}
#else {
#    echo "File cannot be upload!\n";
#    echo "Error: " . $_FILES["file"]["error"];
#    echo 'Here is some more debugging info:';
#    print_r($_FILES);
#    
#}

print "</pre>";
?>
