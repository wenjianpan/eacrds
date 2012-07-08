<?php
// TODO: remove this before going production
error_reporting(E_ALL & ~E_NOTICE);

$IMAGE_DIR = "card_pics/";

/**
 * Splits url into array of it's pieces as follows:
 * [scheme]://[user]:[pass]@[host]/[path]?[query]#[fragment]
 * In addition it adds 'query_params' key which contains array of
 * url-decoded key-value pairs
 *
 * @param String $url Url
 * @return Array Parsed url pieces
 */
function url_get_params($url) {
  $url_arr = parse_url($url);
  $url_arr['query_params'] = array();
  $query_pairs = explode('&', $url_arr['query']);
  foreach($query_pairs as $query_pair) {
    if (trim($query_pair) == '') {
      continue;
    }
    list($key, $val) = explode('=', $query_pair);
    $url_arr['query_params'][$key] = urldecode($val);
  }
  return $url_arr;
}

function emailqueue_get_next_id_from_url() {
  // find url
  $url = $_SERVER["REQUEST_URI"];
  if (!$url) {
    return null;
  }
  // get all url params
  $url_arr = url_get_params($url);
  // find the query param like in "id=1734"
  return isset($url_arr['query_params']['id']) ?
    $url_arr['query_params']['id'] :
    null;
}
function emailqueue_get_next_sender_from_url() {
  // find url
  $url = $_SERVER["REQUEST_URI"];
  if (!$url) {
    return null;
  }
  // get all url params
  $url_arr = url_get_params($url);
  // find the query param like in "id=1734"
  return isset($url_arr['query_params']['sender']) ?
    $url_arr['query_params']['sender'] :
    null;
}
function emailqueue_get_next_receiver_from_url() {
  // find url
  $url = $_SERVER["REQUEST_URI"];
  if (!$url) {
    return null;
  }
  // get all url params
  $url_arr = url_get_params($url);
  // find the query param like in "id=1734"
  return isset($url_arr['query_params']['receiver']) ?
    $url_arr['query_params']['receiver'] :
    null;
}
function emailqueue_get_next_msg_from_url() {
  // find url
  $url = $_SERVER["REQUEST_URI"];
  if (!$url) {
    return null;
  }
  // get all url params
  $url_arr = url_get_params($url);
  // find the query param like in "id=1734"
  return isset($url_arr['query_params']['msg']) ?
    $url_arr['query_params']['msg'] :
    null;
}
// get the task id to process from the url
function emailqueue_get_email_info($id) {
  // sanity check
  if (!$id) {
    return null;
  }

  $link = mysql_get_connection();

  // find the task detail
  $query = sprintf("select * from email_queue where id = %d;",
                   $id);

  // Perform Query
  $result = mysql_query($query, $link);

  // Check result
  if (!$result) {
    $message  = 'Invalid query: ' . mysql_error() . "\n";
    $message .= 'Whole query: ' . $query;
    die($message);
  }

  // Use result
  $row = mysql_fetch_assoc($result);
  mysql_close($link);

  return $row;
}

function mysql_get_connection() {
  static $link;
  if($link) {
    return $link;
  }
  $link = mysql_connect('localhost', 'root', 'root') or die('Could not connect to mysql server.' );
  mysql_select_db('card_development', $link) or die('Could not select database.');
  return $link;
}
function emailqueue_get_post_msg() {
	return isset($_POST["username"]) ?
		$_POST["username"] :
		null;
}
function emailqueue_get_post_img() {
	return isset($_POST["img"]) ?
		$_POST["img"] :
		null;
}
function emailqueue_get_post_filename() {
	return isset($_POST["Filename"]) ?
		$_POST["Filename"] :
		null;
}
function emailqueue_get_post_filedata() {
	return isset($_POST["Filedata"]) ?
		$_POST["Filedata"] :
		null;
}
?>
