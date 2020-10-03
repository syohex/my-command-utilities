#!/usr/bin/env perl
use strict;
use warnings;

use 5.014;

use Encode ();
use HTTP::Tiny ();

my $MIT_LICENSE_TMPL = <<'MIT_LICENSE';
The MIT License (MIT)

Copyright (c) ##YEAR## ##NAME##

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
MIT_LICENSE

my %LICENSE = (
    "mit" => $MIT_LICENSE_TMPL,
);

my %LICENSE_URL = (
    "gpl3" => {
        url => "http://www.gnu.org/licenses/gpl-3.0.txt",
        cb  => sub {
            my $content = shift;
            return Encode::decode_utf8($content);
        },
    },
);

my $arg = shift or help();
if ($arg eq '-h' or $arg eq '--help') {
    help();
}

my $type = lc $arg;

my $output;
if (exists $LICENSE{$type}) {
    my $tmpl = $LICENSE{$type};
    $output = fill_parameters($tmpl);
} elsif (exists $LICENSE_URL{$type}) {
    my $info = $LICENSE_URL{$type};
    my $url = $info->{url};
    my $cb = $info->{cb};

    my $res = HTTP::Tiny->new->get($url);
    unless ($res->{success}) {
        die "Download failed: $url\n";
    }

    $output = $cb->($res->{content});
} else {
    die "Error: '$arg' license is not supported\n";
}

print $output;

sub help {
    say "Usage: license-gen.pl [GPL3|MIT]";
    exit 0;
}

sub this_year {
    return (localtime)[5] + 1900;
}

sub name_from_git {
    my $name = `git config --get user.name`;
    chomp $name;
    return $name;
}

sub fill_parameters {
    my $tmpl = shift;

    my $year = this_year();
    my $name = name_from_git();

    $tmpl =~ s{##YEAR##}{$year}eg;
    $tmpl =~ s{##NAME##}{$name}eg;

    return $tmpl;
}
