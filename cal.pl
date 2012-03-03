#!/usr/bin/env perl

package App::Cal;
use strict;
use warnings;

use Carp ();
use Calendar::Simple ();
use Calendar::Japanese::Holiday ();
use Getopt::Long ();
use List::MoreUtils qw(any);
use Term::ANSIColor qw(:constants);

use Encode ();
use Encode::Locale;

sub new {
    my $class = shift;
    bless { show_year => 0 }, $class;
}

sub run {
    my $self = shift;

    local @ARGV = @_;
    Getopt::Long::GetOptions(
        'y|year=i'  => \$self->{year},
        'm|month=i' => \$self->{month},
        'h|help'    => \my $help,
    );

    if ($help) {
        print <<"...";
Usage: $0 [options]

  Options
    -y,--year     Specify year
    -m,--month    Specify month
    -h,--help     Show this message
...
        exit 1;
    }

    $self->_validate;

    my @cals;
    if ($self->{show_year}) {
        push @cals, $self->_get_colored_cal_year;
    } else {
        push @cals, $self->_get_colored_cal($self->{year}, $self->{month});
    }

    my $index = 1;
    for my $cal (@cals) {
        my $mon = $self->{month} || $index;
        printf "%9s %s\n", _month_name($mon), $self->{year};
        for my $week (@{$cal}) {
            for my $day ( @{$week} ) {
                print "$day ";
            }
            print "\n";
        }
        $index++;
        print "\n";
    }

    $self->_show_holiday unless $self->{show_year};
}

my @month_names = qw/Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec/;
sub _month_name {
    my $mon = shift;
    return $month_names[$mon - 1];
}

sub _show_holiday {
    my $self = shift;

    print "Holidays \n";
    my $has_holiday = 0;
    for my $day (sort { $a <=> $b }keys %{$self->{holidays_info}}) {
        printf "%2d: %s\n", $day,
        Encode::encode('console_out', $self->{holidays_info}->{$day});

        $has_holiday = 1;
    }

    unless ($has_holiday) {
        print "This month has no holidays !!!!\n";
    }
}

sub _get_colored_cal_year {
    my $self = shift;

    my $year = $self->{year};
    my @cals;
    for my $mon (1..12) {
        push @cals, $self->_get_colored_cal($year, $mon);
    }

    return @cals;
}

sub _get_colored_cal {
    my ($self, $year, $mon) = @_;

    my @cal_datas = Calendar::Simple::calendar($mon, $year);
    return [ $self->_color_holidays(\@cal_datas, $year, $mon) ];
}

my @week_names = qw/Su Mo Tu We Th Fr Sa/;

sub _color_holidays {
    my ($self, $cal_data_ref, $year, $mon) = @_;

    my $holidays_info = Calendar::Japanese::Holiday::getHolidays($year, $mon, 1);
    $self->{holidays_info} = $holidays_info;

    my @holidays = keys %{$holidays_info};

    my $this_month_flag = _is_this_month($year, $mon);
    my $mday = (localtime)[3];

    my @colored;
    push @colored, [ @week_names ];
    for my $week ( @{$cal_data_ref} ) {
        my @days;
        my $index = 0;
        for my $day ( @{$week} ) {
            my $d;
            if (defined $day) {
                $d = sprintf "%2d", $day;
                if ($this_month_flag && $day == $mday) {
                    $d = BLACK . ON_WHITE . $d . RESET;
                } elsif ($index == 0 || any { $d == $_ } @holidays) {
                    $d = BOLD . RED . $d . RESET;
                } elsif ($index == 6) {
                    $d = BOLD . CYAN . $d . RESET;
                }
            } else {
                $d = '  ';
            }

            push @days, $d;
            $index++;
        }
        push @colored, [ @days ];
    }

    return @colored;
}

sub _is_this_month {
    my ($year, $month) = @_;

    my ($m, $y) = (localtime)[4, 5];
    return ($y + 1900) == $year && ($m + 1) == $month;
}

sub _validate {
    my $self = shift;

    my $year_undefined;
    if ($self->{year}) {
        my $year = $self->{year};
        unless ($year >= 0) {
            Carp::croak("'year' option should >= 0($year)");
        }
    } else {
        $year_undefined = 1;
        $self->{year} = (localtime)[5] + 1900;
    }

    if ($self->{month}) {
        my $mon = $self->{month};
        unless ($mon >= 1 && $mon <= 12) {
            Carp::croak("Invalid month(0 <= month <= 12)");
        }
    } else {
        if ($year_undefined) {
            $self->{month} = (localtime)[4] + 1;
        } else {
            $self->{show_year} = 1;
        }
    }
}

package main;
use strict;
use warnings;

unless (caller) {
    my $cal = App::Cal->new;
    $cal->run(@ARGV);
}
