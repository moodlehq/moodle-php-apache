<?php

$requiredextensions = [
    'apcu',
    'gd',
    'igbinary',
    'intl',
    'ldap',
    'memcached',
    'mysqli',
    'oci8',
    'pgsql',
    'redis',
    'solr',
    'soap',
    'sqlsrv',
    'xsl',
    'xmlrpc',
    'zip',
];

$buffer = '';;
$missing = [];
foreach($requiredextensions as $ext) {
    if (!extension_loaded($ext)) {
        $missing[] = $ext;
    }
}

$locale = 'en_AU.UTF-8';
if (setlocale(LC_TIME, $locale) === false) {
    $missing[] = $locale;
}

if (php_sapi_name() === 'cli') {
    if (empty($missing)) {
        echo "OK\n";
        exit(0);
    }
    echo 'Missing: '.join(', ', $missing)."\n";
    exit(1);
} else {
    if (empty($missing)) {
        header('HTTP/1.1 200 - OK');
        exit(0);
    } else {
        header('HTTP/1.1 500 - Problem PHP extension missing: ' . join(', ', $missing));
        exit(1);
    }
}
