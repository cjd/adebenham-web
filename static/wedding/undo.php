<?PHP $title="title-registry.png";include ("head.tmpl");
import_request_variables("GPC","");
$fd = fopen("gifts.list","r+");
$stack=array();
while (!feof($fd)) {
    $line = fgets($fd,4096);
    list($count,$item)=explode(";",$line,2);
    $item=rtrim($item);
    if ($item == $undo) {
        if ($count >= 0) {
            $count++;
        }
    }
        array_push($stack,$count.";".$item."\n");
}

rewind($fd);
foreach ($stack as $item) {
    if ($item != ";\n"){
        #fwrite($fd,$item);
    }
}
fclose ($fd);
?>
                              <div style="text-align: center;">
                                I have re-added "<?php echo $undo?>"
<br />
Return to the list by clicking <a href="registry.php">here</a><br/>
                              </div>

<?PHP include ("foot.tmpl"); ?>
