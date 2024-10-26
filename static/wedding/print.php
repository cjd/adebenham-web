<html>
<body bgcolor=white>
<h1>Melissa and Chris' Bridal Registry</h1>
<h2>Printable version</h2>
<?PHP
        $fd2 = fopen("gifts.list","r");
        while (!feof($fd2)) {
            $entry=fgets($fd2,4096);
            list($count,$item) = explode(";",$entry,2);
            if ($count > 0 ) {
                echo "<li>".$item."</li>\n";
            }
        }
        fclose($fd2);
?>
<br/>
<a href="registry.php">Go back to registy page</a>
</body>
</html>
