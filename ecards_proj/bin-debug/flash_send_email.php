<?php
require_once('./flash_lib.php');


$sender_email = isset($_POST["Sender"]) ? $_POST["Sender"] :	null;
$receiver_email = isset($_POST["Receiver"]) ? $_POST["Receiver"] :	null;
$sender_name = isset($_POST["SenderName"]) ? $_POST["SenderName"] :	null;
$sender_name = ucfirst(strtolower($sender_name));
$receiver_name = isset($_POST["ReceiverName"]) ? $_POST["ReceiverName"] :	null;
$receiver_name = ucfirst(strtolower($receiver_name));
$message =  isset($_POST["Content"]) ? $_POST["Content"] :	null;

$id = emailqueue_insert_message($sender_name,
                                $receiver_name,
                                $message);
if (!$id) {
  echo "There was an error sending the card, please try again!";
  exit();
}

//echo "\n new id is: $id \n\n";

//save image into upload director
$target_path = $IMAGE_DIR;
//here need huai change the tmp.jpg into the $id.jpg; id is the unique id to different with other pic
$target_path = $target_path ."$id.jpg";
if(move_uploaded_file($_FILES['Filedata']['tmp_name'], $target_path)) {
   // echo "The file ".  basename( $_FILES['Filedata']['name']).
   // " has been uploaded";
} else{
    echo "There was an error uploading the file, please try again!";
    exit();
}


$res = emailqueue_send_mail($sender_email, $receiver_email, $message,$id,$sender_name,$receiver_name);
if($res == 1)
{
	$res = emailqueue_send_mail_self($sender_email, $receiver_email, $message,$id,$sender_name,$receiver_name);
	if($res == 1)
	{
		echo "1";
	}
	else
		echo "0";
}
else
	echo "0";


////////////////////////////////////////////////////////////
// libraries
////////////////////////////////////////////////////////////
/**
 * insert an email into the email queue
 *
 * TODO: the new email task should be marked with status "inserted",
 *       and when sending started, mark to "sending"
 *       and when sent successfully, mark to "sent"
 */
function emailqueue_insert_message($sender_email,
                                   $receiver_email,
                                   $message
                                   ) {
  $link = mysql_get_connection();

 // echo $message;
  // find the task detail
  $query = sprintf('insert into email_queue '.
                   '(sender_email, receiver_email, message) values '.
                   '("%s", "%s", "%s");',
                   $sender_email, $receiver_email, $message);

  // Perform Query
 // echo $query;
  $result = mysql_query($query, $link);
  if (!$result) {
    return null;
  }
  return mysql_insert_id($link);
}

function emailqueue_send_mail($sender_email, $receiver_email, $message,$id,$sender_name,$receiver_name) {
/*
  //create a boundary string. It must be unique
  //so we use the MD5 algorithm to generate a random hash
  // $random_hash = md5(date('r', time()));
  //define the headers we want passed. Note that they are separated with \r\n
  //$headers = "From: webmaster@ecardapps.com\r\nReply-To: webmaster@ecardapps.com";
  $headers = "From: $sender_email\r\nReply-To: $sender_email";
  //add boundary string and mime type specification
  $headers .= "\r\nContent-Type: multipart/mixed; boundary=\"PHP-mixed-".$random_hash."\"";
*/


  $headers  = 'MIME-Version: 1.0' . "\r\n";
  $headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";

  // Additional headers
  //$headers .= "To: $receiver_email" . "\r\n";
  $headers .= 'From: EcardApps.com <webmaster@ecardapps.com>' . "\r\n";
  $headers .= "Reply-To: $sender_email" . "\r\n";
  //$headers .= "Cc: $sender_email". "\r\n";
  //$headers .= 'Bcc: birthdaycheck@example.com' . "\r\n";
  //here need huai change the link
  $body = '<html> <head> <title>Birthday Card</title> </head> <body> <p>'.
          "Hi,$receiver_name<br>  $sender_name($sender_email) just sent you an ecard from <a href=\"http://www.ecardapps.com\">eCardapps.com</a><br>".
					"You can view it by clicking <a href=\"http://www.ecardapps.com/flash_read_email.php?id=". $id. "\">here</a><br>".
					"Do you want to send an eCard back to $sender_name($sender_email)? Go to our website at <a href=\"Http://ecardapps.com/index.html\">eCardapps.com</a><br>".
					"We hope you enjoy the eCard.<br>".
					"eCardapps.com team<br>".
					"http://ecardapps.com/index.html<br>".
          '</p> </body> </html> ';

  /*
  //read the atachment file contents into a string,
  //encode it with MIME base64,
  //and split it into smaller chunks
  // $attachment = chunk_split(base64_encode(file_get_contents('./pics/image1.jpg')));
  //define the body of the message.
  $body = '';
  $body .= '--PHP-mixed-'. $random_hash. " \n ";
  $body .= 'Content-Type: multipart/alternative; boundary="PHP-alt-'. $random_hash;
  $body .= " \n ";

  $body .= '--PHP-alt-'. $random_hash. " \n ";
  $body .= 'Content-Type: text/plain; charset="iso-8859-1" '.
  $body .= " \n ";
  $body .= 'Content-Transfer-Encoding: 7bit ';
  $body .= " \n ";
  $body .= $message;
  $body .= " \n ";

  $body .= '--PHP-alt-'. $random_hash. " \n ";
  $body .= 'Content-Type: text/html; charset="iso-8859-1" '.
  $body .= " \n ";
  $body .= 'Content-Transfer-Encoding: 7bit ';
  $body .= " \n ";
  $body .= "<h2> $message </h2>";
  $body .= "<p>This is something with <b>HTML</b> formatting.</p>";
  $body .= " \n ";

  $body .= '--PHP-alt-'. $random_hash. "-- \n ";
  */

  //send the email
  $mail_sent = mail($receiver_email,
                    $subject = "Hi $receiver_name, $sender_name has just sent you an eCard!",
                    $body,
                    $headers);
  //if the message is sent successfully print "Mail sent". Otherwise print "Mail failed"
  return $mail_sent;
}
function emailqueue_send_mail_self($sender_email, $receiver_email, $message,$id,$sender_name,$receiver_name) {

  $headers  = 'MIME-Version: 1.0' . "\r\n";
  $headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";

  $headers .= 'From: EcardApps.com <webmaster@ecardapps.com>' . "\r\n";
  $headers .= "Reply-To: $sender_email" . "\r\n";
  
  $body = '<html> <head> <title>Birthday Card</title> </head> <body> <p>'.
           "Your ecard has been sent to $receiver_name($receiver_email)".
					 "<br><br>You can view a copy of your ecard <a href=\"http://www.ecardapps.com/flash_read_email.php?id=". $id. "\">here</a>".
					 "<br><br>Thanks for choosing <a href=\"http://www.ecardapps.com\">ecardapps.com</a>".
					 "<br><br>ecardapps team<br>ecardapps.com".
         '</p> </body> </html> ';

  $mail_sent = mail($sender_email,
                    $subject = "Hi $sender_name, your eCard has been sent successfully!",
                    $body,
                    $headers);
  //if the message is sent successfully print "Mail sent". Otherwise print "Mail failed"
  return $mail_sent;
}

?>

