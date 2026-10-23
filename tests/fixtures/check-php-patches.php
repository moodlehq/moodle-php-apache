<?php

// Checks that the PHP binary was built with the CVE-2026-109618 / CVE-2026-109619 (PHP2Shell) backport.
// PHP_BUILD_PROVIDER is set by the php-base stage in the Dockerfile and shown in phpinfo().

$allokay = true;
$message = [];

ob_start();
phpinfo(INFO_GENERAL);
$info = ob_get_clean();

if (strpos($info, 'CVE-2026-109618/109619') === false) {
    $allokay = false;
    $message[] = "PHP was not built with the CVE-2026-109618/109619 backport (Build Provider not found).";
}

// opcache is rebuilt by the Moodle setup, so check that its .so also contains the patched code.
$opcache = ini_get('extension_dir') . '/opcache.so';
if (strpos((string) file_get_contents($opcache), 'zend_accel_pending_ce_cache_begin') === false) {
    $allokay = false;
    $message[] = "opcache.so does not contain the CVE-2026-109619 backport (rebuilt from unpatched source?).";
}

if ($allokay) {
    echo "OK\n";
} else {
    http_response_code(500);
    echo implode("\n", $message) . "\n";
    exit(1);
}
