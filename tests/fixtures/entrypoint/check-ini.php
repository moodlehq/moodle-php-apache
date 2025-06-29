<?php

$allokay = true;
$message = [];

$fileuploads = ini_get('file_uploads');
if (!empty($fileuploads)) {
    $allokay = false;
    $message[] = "Uploads are enabled and should be disabled.";
    $message[] = var_export($fileuploads, true);
}

$apcenabled = ini_get('apc.enabled');
if (!empty($apcenabled)) {
    $allokay = false;
    $message[] = "apc.enabled is not Off (0): ({$apcenabled})";
}

$apcenabledcli = ini_get('apc.enabled_cli');
if (!empty($apcenabledcli)) {
    $allokay = false;
    $message[] = "apc.enabled_cli is not Off (0): ({$apcenabledcli})";
}

$memorylimit = ini_get('memory_limit');
if ($memorylimit !== '256M') {
    $allokay = false;
    $message[] = "Memory limit not set to 256M: ({$memorylimit})";
}

$pcovenabled = ini_get('pcov.enabled');
if (empty($pcovenabled)) {
    $allokay = false;
    $message[] = "pcov.enabled is not On (1): ({$pcovenabled})";
}

$maxuploadsize = ini_get('upload_max_filesize');
if ($maxuploadsize !== '20M') {
    $allokay = false;
    $message[] = "Maximum upload size not set to 20M: ({$maxuploadsize})";
}

$postmaxsize = ini_get('post_max_size');
if ($postmaxsize !== '206M') {
    $allokay = false;
    $message[] = "Maximum post size not set to 206M: ({$postmaxsize})";
}

$xhprof = extension_loaded('xhprof');
if (!$xhprof) {
    $allokay = false;
    $message[] = "xhprof extension not loaded (should be enabled)";
}

$xdebug = extension_loaded('xdebug');
if ($xdebug) {
    $allokay = false;
    $message[] = "xdebug extension loaded (should be disabled)";
}

if (php_sapi_name() === 'cli') {
    if ($allokay) {
        echo "OK\n";
        exit(0);
    }

    echo implode("\n", $message) . "\n";
    exit(1);
} else {
    if ($allokay) {
        header('HTTP/1.1 200 - OK');
        exit(0);
    }

    header('HTTP/1.1 500 - ' . implode(", ", $message));
    echo implode("<br>", $message);
    exit(1);
}
