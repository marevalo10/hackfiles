#!/usr/bin/perl
# Simple wrapper to run multiple .spk files using generic_send_tcp

$spikese = '/usr/bin/generic_send_tcp';

if ($ARGV[4] eq '') {
    die("Usage: $0 IP_ADDRESS PORT SKIPFILE SKIPVAR SKIPSTRnn");
}

$skipfiles = $ARGV[2];
@files = <*.spk>;
foreach $file (@files) {
    if (! $skipfiles) {
        if (system("$spikese $ARGV[0] $ARGV[1] $file $ARGV[3] $ARGV[4]") ) {
            print "Stopped processing file $filen";
            exit(0);
        }
    } else {
        $skipfiles--;
    }
}