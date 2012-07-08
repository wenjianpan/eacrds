<?php


$target_path = "/home/apache/tmp/";

$target_path = $target_path . basename( $_FILES['uploadedfile']['name']); 
echo $_POST['Filename'];
echo '<br>';
echo $target_path;
echo '<br>';
echo $_FILES['uploadedfile']['name'];
echo '<br>';
echo $_FILES['uploadedfile']['tmp_name'];
echo '<br>';
echo $PHP_SELF;
echo '<br> name:';
echo $_FILES['uploadedfile']['name'];
echo '<br> tmpname:';
echo $_FILES['uploadedfile']['tmp_name'];
echo '<br> size:';
echo $_FILES['uploadedfile']['size'];
echo '<br> type:';
echo $_FILES['uploadedfile']['type'];

if(move_uploaded_file($_FILES['uploadedfile']['tmp_name'], $target_path)) {
    echo "The file ".  basename( $_FILES['uploadedfile']['name']). 
    " has been uploaded";
} else{
    echo "There was an error uploading the file, please try again!";
}
?>