<?php

/**
 * This script is run by /etc/rc.d/rc.local to fetch user-data variables
 */

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://169.254.169.254/latest/user-data');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$rawUserData = curl_exec($ch);
curl_close($ch);

parse_str($rawUserData, $parsedUserData);

if (isset($parsedUserData[$argv[1]]))
{
    echo $parsedUserData[$argv[1]];
}
else
{
    echo 'KEY_NOT_FOUND';
}

