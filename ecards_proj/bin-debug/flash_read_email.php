<?php
require_once('./flash_lib.php');
require_once('./flash_display_lib.php');

$id = emailqueue_get_next_id_from_url();
$card_info = emailqueue_get_email_info($id);

//print_r($card_info);

$card_image = $IMAGE_DIR. "$id.jpg";
//$wood_background   = 'pics/wood_background.png';
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
$html .= 'To: '. txt2html($card_info['receiver_email']);
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
           substr($card_info['message'], 0, 200));
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
$html .= txt2html($card_info['sender_email']);
$html .= render_close_div();

$html .= render_close_div();


$html .= render_div('card_pic', 'section');
$html .= '<img src="'. $card_image. '" />';
$html .= render_close_div();

$html .= render_close_div(); // card_wrapper
echo $html;

?>
