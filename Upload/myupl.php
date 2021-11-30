<?php
$uploaddir = '/var/www/uploads/'; 
$uploadfile = $uploaddir . basename($_FILES['file']['name']);
echo '<pre>';
echo 'Received File: ' . $uploadfile;
echo 'Temporary name: ' . $_FILES['file']['tmp_name'];
// Check if file was uploaded without errors
if(isset($_FILES['file']) && $_FILES['file']['error'] == 0){
    if (move_uploaded_file($_FILES['file']['tmp_name'], $uploadfile)) {
        echo "File is valid, and was successfully uploaded.\n";
    } 
    else {
        echo "Possible file upload issue!\n";
    }
}
else {
    echo "File cannot be upload!\n";
    echo "Error: " . $_FILES["file"]["error"];
    echo 'Here is some more debugging info:';
    print_r($_FILES);
    
}

print "</pre>";
?>