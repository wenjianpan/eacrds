<?php
function render_div($id, $class) {
  return '<div id="'. $id. '" class="'. $class. '" >';
}

function render_close_div() {
  return '</div>';
}

/**
 * to convert text to html to prevent xss attack
 */
function txt2html($text) {
  return htmlspecialchars($text);
}
?>
