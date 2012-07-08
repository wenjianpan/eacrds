<?php
require_once('./flash_lib.php');
require_once('./flash_display_lib.php');

$sender_email = isset($_POST["Sender"]) ? $_POST["Sender"] :	null;
$receiver_email = isset($_POST["Receiver"]) ? $_POST["Receiver"] :	null;
$contentmsg =  isset($_POST["Content"]) ? $_POST["Content"] :	null;
$sender_name = isset($_POST["SenderName"]) ? $_POST["SenderName"] :	null;
$sender_name = ucfirst(strtolower($sender_name));
$receiver_name = isset($_POST["ReceiverName"]) ? $_POST["ReceiverName"] :	null;
$receiver_name = ucfirst(strtolower($receiver_name));
//save image into upload director
$target_path = $IMAGE_DIR;
//here need huai change the tmp.jpg into the $id.jpg; id is the unique id to different with other pic 

//$target_path = $target_path .basename( $_FILES['Filedata']['tmp_name']).'.jpg';
$target_path = $target_path .basename( $_FILES['Filedata']['tmp_name']).'.jpg';

$path = $IMAGE_DIR;
$dir_handle = opendir($path) or die("Unable to open folder");
while (false !== ($file = readdir($dir_handle)))
{
	$tmp_file_path = $IMAGE_DIR. $file;
  unlink($tmp_file_path);
}
closedir($dir_handle);


if(move_uploaded_file($_FILES['Filedata']['tmp_name'], $target_path)) {
  //  echo "The file ".  basename( $_FILES['Filedata']['name']).
  //  " has been uploaded";
} else{
    echo "There was an error uploading the file, please try again!";
    exit();
}
//echo 'upload file name:';
//echo $target_path;
//print_r($card_info);

$card_image = $target_path;
$letter_background = 'pics/letter_background.png';
$pin_img = 'pics/pin.png';

$html  = '';

$html .= '<link rel="stylesheet" type="text/css" href="read_card.css" />';

$html .= render_div('card_wrapper', 'wrapper');

/*
// render wood_background
$html .= render_div('wood_background', 'background');
$html .= '<img src="'. $wood_background. '" />';
$html .= render_close_div();
*/

// render letter_background
$html .= render_div('letter_background', 'background');
$html .= '<img src="'. $letter_background. '" />';
$html .= render_close_div();

// render pin_img
$html .= render_div('pin_img', 'background');
$html .= '<img src="'. $pin_img. '" />';
$html .= render_close_div();

// receiver
$html .= render_div('receiver', 'section');

/*
$html .= render_div('receiver_label', 'name_lable');
$html .= 'To:';
$html .= render_close_div();
*/

$html .= render_div('receiver_email', 'email email_font');
$html .= 'To: '. txt2html($receiver_name);
$html .= render_close_div();

$html .= render_close_div();


// message
$html .= render_div('message', 'section');

/*
$html .= render_div('message_label', 'name_lable');
$html .= 'Message:';
$html .= render_close_div();
*/

$html .= render_div('message_content', 'message email_font');
$html .= txt2html(
           substr($contentmsg, 0, 200));
$html .= render_close_div();

$html .= render_close_div();


// sender
$html .= render_div('sender', 'section');

/*
$html .= render_div('sender_label', 'name_lable');
$html .= 'From:';
$html .= render_close_div();
*/

// only take the 200 characters.
$html .= render_div('sender_email', 'email email_font');
$html .= txt2html($sender_name);
$html .= render_close_div();

$html .= render_close_div();


$html .= render_div('card_pic', 'section');
$html .= '<img src="'. $card_image. '" />';
$html .= render_close_div();

$html .= render_close_div(); // card_wrapper
echo $html;
 
?>