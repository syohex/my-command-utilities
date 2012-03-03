#!/usr/bin/env perl
package App::PSPrinter;
use strict;
use warnings;

use Getopt::Long;
use Carp qw(croak carp);

use utf8;
use File::Basename;
use File::Temp ();

binmode STDOUT, ":utf8";

sub new {
    my $class = shift;

    bless {
        printer   => $ENV{PRINTER},
        duplex    => 'none',
        up        => 1,
        num       => 1,
    }, $class;
}

sub parse_options {
    my $self = shift;

    local @ARGV = @_;
    Getopt::Long::GetOptions(
        'p|printer=s' => \$self->{printer},
        'd|duplex=s'  => \$self->{duplex},
        'u|up=i'      => \$self->{up},
        'n|num=i'     => \$self->{num},
        'h|help'      => \$self->{help},
    );

    $self->_usage if defined $self->{help};

    $self->{argv} = \@ARGV;
    $self->_validate();
}

sub _validate {
    my $self = shift;

    croak("Error not specified printer\n") unless $self->{printer};

    unless (_get_duplex_option($self->{duplex})) {
        croak("invalid 'duplex' option. It should be (none|short|long)\n")
    }

    croak("Not specified PS files\n") if scalar @{$self->{argv}} == 0;
}

sub _get_print_message {
    my $self = shift;
    my %duplex_str = (
        none  => "なし", short => "短辺", long  => "長辺"
    );

    return "両面印刷:" . $duplex_str{$self->{duplex}} . " $self->{up}段組";
}

sub _get_duplex_option {
    my %duplex_option = (
        none  => 'None', long  => 'DuplexNoTumble', short => 'DuplexTumble',
    );

    return $duplex_option{$_[0]};
}

sub _usage {
    print <<__USAGE__;
Usage $0 [options] psfiles [...]

Options:
  -p,--printer          Printer name. Default is \$ENV{PRINTER}.
  -d,--duplex           Duplex printing(none|short|long). Default is none.
  -u,--up               n-up printing(1, 2, 4, 8...). Default is 1.
  -n,--num              Number of priting.
  -h,--help             Show usage.
__USAGE__

    exit 0;
}

sub prompt {
    my $message = shift;

    print $message, " (yes or no) ";

    while (1) {
        my $input = <STDIN>;
        $input =~ s{\r*\n*}{}g;

        last if $input eq 'yes';
        exit if $input eq 'no';

        print "\n", "input again(yes or no) ";
    }

    return 1;
}

sub run {
    my $self = shift;

    my @files = @{$self->{argv}};

    for my $file (@files) {
        my (undef, $tempfile) = File::Temp::tempfile(
            SUFFIX => '.ps', UNLINK => 1, DIR => '.',
        );

        unless ($file =~ m{\.ps$}) {
            my @cmd = (qw/u2ps -o/, $tempfile, $file);
            system(@cmd) == 0 or die "Can't exec '@cmd'";
            system("evince", $tempfile) == 0 or die "Can't exec '@cmd'";
            $file = $tempfile;
        }
        croak("$file is not psfile\n") unless $file =~ m{\.ps$};

        unless (-e $file) {
            carp "$file not found\n";
            next;
        }

        my @command = (
            'lpr', '-P', $self->{printer},
            '-o', 'number-up=' . $self->{up},
            '-o', 'Duplex=' . _get_duplex_option($self->{duplex}),
            $file,
        );

        my $base = File::Basename::basename($file);
        my $message = "[$self->{printer}] $base" . $self->_get_print_message;

        if (prompt "$message 印刷しますか ? ", '-yes_no') {
            my $status = system(@command);
            if ($status != 0) {
                croak "Can't print $base\n";
            }
            print "${base}の印刷に成功しました\n";
        }
    }
}

1;

package main;
use strict;
use warnings;

unless (caller) {
    my $app = App::PSPrinter->new;
    $app->parse_options(@ARGV);
    $app->run();
}
