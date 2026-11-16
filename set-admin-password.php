<?php
// Sets SnappyMail's admin panel password (login "admin") to $SNAPPYMAIL_ADMIN_PASSWORD.
// The stored value is a password_hash(), the same format SnappyMail writes itself.
// Runs on every boot, so the Railway variable stays the source of truth.
$file = $argv[1];
$password = (string) getenv('SNAPPYMAIL_ADMIN_PASSWORD');
if ($password === '') {
    exit(0);
}
$ini = file_get_contents($file);
if ($ini === false) {
    fwrite(STDERR, "[railway] cannot read $file\n");
    exit(1);
}
if (preg_match('/^admin_password\s*=\s*"([^"]*)"/m', $ini, $m) && $m[1] !== '' && password_verify($password, $m[1])) {
    echo "[railway] admin password already matches SNAPPYMAIL_ADMIN_PASSWORD\n";
    exit(0);
}
$hash = password_hash($password, PASSWORD_DEFAULT);
$ini = preg_replace_callback('/^admin_password\s*=.*$/m', function () use ($hash) {
    return 'admin_password = "' . $hash . '"';
}, $ini, 1, $count);
if ($count !== 1) {
    fwrite(STDERR, "[railway] admin_password line not found in $file\n");
    exit(1);
}
file_put_contents($file, $ini);
// The "weak password" file only exists when SnappyMail generated the password itself.
@unlink(dirname($file, 2) . '/admin_password.txt');
echo "[railway] admin password set from SNAPPYMAIL_ADMIN_PASSWORD (login: admin)\n";
