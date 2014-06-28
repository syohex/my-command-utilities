#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec;

my $file = File::Spec->catfile($ENV{HOME}, ".chpwd-recent-dirs");
open my $fh, '<', $file or die "Can't open file $!";

my $not_registered_regexp = qr{/\.(?:cask|ghq)(?:/|$)};

my @lives;
my $deleted = 0;
while (my $line = <$fh>) {
    chomp $line;

    if ($line =~ m{\A\$'(.+)'\z}) {
        my $dir = $1;

        unless (-d $dir) {
            $deleted++;
            next;
        }

        if ($dir =~ $not_registered_regexp) {
            $deleted++;
            next;
        }

        push @lives, $line;
    }
}
close $fh;

open my $wfh, '>', $file or die "Can't open file $!";
print {$wfh} join("\n", @lives);
print {$wfh} "\n";
close $wfh;

print "Delete $deleted directories\n";
