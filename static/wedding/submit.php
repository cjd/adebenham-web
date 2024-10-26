<?PHP $title="title-registry.png";include ("head.tmpl");
import_request_variables("GPC","");
$fd = fopen("gifts.list","r+");
$stack=array();
while (!feof($fd)) {
    $line = fgets($fd,4096);
    list($count,$item)=explode(";",$line,2);
    $item=rtrim($item);
    if ($item == $giftlist) {
        if ($count > 0) {
            $count--;
        }
    }
    array_push($stack,$count.";".$item."\n");
}

rewind($fd);
foreach ($stack as $item) {
    if ($item != ";\n") {
        #fwrite($fd,$item);
    }
}
fclose ($fd);
?>
                              <div style="text-align: center;">
                                Thank you for your choice of <?php echo $giftlist ?>
<br />
If you accidentally chose the wrong item then click <a href="undo.php?undo=<?php echo $giftlist; ?>">here</a><br/>
<br/>
Otherwise choose somewhere else from the side menu to continue<br/>
Or <a href="registry.php">return to registry</a><br/>
                              </div>

<?PHP include ("foot.tmpl"); ?>
