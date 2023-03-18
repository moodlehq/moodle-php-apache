<?php

$uploadsEnabled = ini_get('file_uploads');

if (php_sapi_name() === 'cli') {
    if (empty($uploadsEnabled)) {
        echo "OK\n";
        exit(0);
    }
    echo "Uploads are enabled and should be disabled.";
    var_dump($uploadsEnabled);
    exit(1);
} else {
    if (empty($uploadsEnabled)) {
        header('HTTP/1.1 200 - OK');
        exit(0);
    }
    header('HTTP/1.1 500 - Uploads are enabled and should be disabled: ' . var_export($uploadsEnabled, true));
    exit(1);
}
