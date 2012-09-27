#!/usr/bin/env perl

package App::Github::RSS;
use strict;
use warnings;

use XML::Feed;
use URI;
use DateTime;
use Getopt::Long qw(:config posix_default no_ignore_case gnu_compat);

sub new {
    my $class = shift;
    bless {
        now => DateTime->now( time_zone => 'UTC' ),
    }, $class;
}

sub run {
    my $self = shift;

    my $limit = 10;
    Getopt::Long::GetOptions(
        "l|limit=i" => \$limit,
        "h|help"    => \my $help,
    );

    _usage() if defined $help;

    my $id = shift @ARGV or _usage();
    my $url = sprintf "https://github.com/%s.atom", $id;
    my $feed = XML::Feed->parse( URI->new($url) ) or die XML::Feed->errstr;

    my $index = 0;
    for my $entry ( $feed->entries ) {
        last if $index >= $limit;

        my $duration = $self->{now} - $entry->modified;
        my $ago;
        if ($duration->delta_days < 1) {
            if ($duration->delta_minutes < 60) {
                $ago = sprintf "%s minutes ago", $duration->delta_minutes;
            } else {
                $ago = sprintf "%d hours ago", int($duration->delta_minutes / 60);
            }
        } else {
            $ago = sprintf "%d days ago", $duration->delta_days;
        }

        printf "(%s) %s\n", $ago, $entry->title;

        $index++;
    }
}

sub _usage {
    die "Usage: $0 [--limit n] github_id";
}

1;

package main;
use strict;
use warnings;

unless (caller) {
    my $app = App::Github::RSS->new();
    $app->run;
}
