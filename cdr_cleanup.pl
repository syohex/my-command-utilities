#!/usr/bin/env perl
use strict;
use warnings;

use File::Spec;

my $file = File::Spec->catfile($ENV{HOME}, ".chpwd-recent-dirs");
open my $fh, '<', $file or die "Can't open file $!";

my $not_registered_regexp = qr{/\.(?:cask|ghq)(?:/|$)};

my @lives;
while (my $line = <$fh>) {
    chomp $line;

    if ($line =~ m{\A\$'(.+)'\z}) {
        my $dir = $1;

        unless (-d $dir) {
            print "$dir is no longer existed\n";
            next;
        }

        if ($dir =~ $not_registered_regexp) {
            print "$dir is not registered\n";
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
