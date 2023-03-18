<?php

$sourced = file_exists('/var/www/data/sourced.txt');
$executed = file_exists('/var/www/data/executed.txt');

if (php_sapi_name() === 'cli') {
    if ($sourced && $executed) {
        echo "OK\n";
        exit(0);
    } else if ($sourced && !$executed) {
        echo "Executable file was not executed";
    } else {
        echo "non-executable file was not sourced";
    }
    exit(1);
} else {
    if ($sourced && $executed) {
        header('HTTP/1.1 200 - OK');
        exit(0);
    } else if ($sourced && !$executed) {
        $message = "Executable file was not executed";
    } else {
        $message = "non-executable file was not sourced";
    }
    header('HTTP/1.1 500 - ' . $message);
    exit(1);
}
