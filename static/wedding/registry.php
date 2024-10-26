<?PHP $title="title-registry.png";include ("head.tmpl"); ?>
                              <div style="text-align: center;">
                                Welcome to our on-line Bridal Registry<br />
                              </div>

                              <div style="text-align: center;">
                                There is also a Bridal Registry available at <a href="http://www.myer.com.au/services/gifts3.asp">Myers</a> under our names<br />
                                <br />
                              </div>Please don't feel restricted to only the items on this list or on the Myers registry. If you have any other weird and wonderful ideas feel free to go with
                              them.<br />
                              <br />
                              <form name="gifts" action="submit.php">
                              Gift suggestions: <select name="giftlist">

<?PHP
        $fd2 = fopen("gifts.list","r");
        while (!feof($fd2)) {
            $entry=fgets($fd2,4096);
            list($count,$item) = explode(";",$entry,2);
            if ($count > 0 ) {
                echo "<option>".$item."</option>\n";
            }
        }
        fclose($fd2);
?>
                              </select> <input type=submit name="dibs" value="Bags this"/><br />
                              If you have chosen an item from this list, please
select it and click on "Bags this"<br />
                              Note that some items may stay on the list even after you have grabbed them (such as cookbooks) since we would like more than one of that item<br />
                              <br />
                              Thanks heaps for being part of this huge event (at least for us it is :-) )<br />
                              Looking forward to seeing you on the 11th March
<br/>
<i>If you have any problems send us an email to <a href="mailto:chris@adebenham.com">chris@adebenham.com</a></i><br/>
<?PHP include ("foot.tmpl"); ?>
