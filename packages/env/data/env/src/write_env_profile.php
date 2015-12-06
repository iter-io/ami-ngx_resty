<?php

/**
 * This script is run by /etc/rc.d/rc.local to generate /etc/profile.d/env.sh
 * when the instance is launched.  It gets the environmental variables from
 * the instance metadata passed by the Autoscaling LaunchConfig.
 */

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://169.254.169.254/latest/user-data');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
$rawUserData = curl_exec($ch);
curl_close($ch);

$kvps = explode('&', $rawUserData);

/**
 * Document the environmental variables each package depends on.
 */
$fh = fopen('/etc/profile.d/env.sh', 'w');

foreach ($kvps as $kvp)
{
    fwrite($fh, "export '" . $kvp . "'\n");
}

chmod('/etc/profile.d/env.sh', 0774);

?>
