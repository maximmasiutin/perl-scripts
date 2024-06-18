#!/usr/bin/env perl

use strict;
use warnings;
use utf8;
use File::Slurp;

my $filename_first  = shift;
my $filename_second = shift;
die "First file name is not specified\n"  unless $filename_first;
die "Second file name is not specified\n" unless $filename_second;
print "Comparing $filename_first and $filename_second...\n";
my %current_results_subtests;
my %current_results_sequences;
my @current_results_leftovers;
my $true  = 1;
my $false = -1;

sub process_file_contents {
    my @contents_array      = split chr(10), $_[0];
    my $last_test_name      = "";
    my $last_test_results   = "";
    my $current_test_number = 0;

    foreach (@contents_array) {
        if (/\xF0\x9F\x93\x99(.+?)\s*$/) { # match lines starting with an "orange book" unicode character
            my $str = $1;
            $str =~ s/^\s+//;    # trim leading spaces
            if ( length($last_test_name) > 0 ) {
                $current_results_subtests{$last_test_name} .=
                  $last_test_results;
            }
            $last_test_results = "";
            if ( length($str) > 0 ) {
                $last_test_name = $str;
                unless ( exists $current_results_sequences{$str} ) {
                    $current_test_number += 1;
                    $current_results_sequences{$str} = $current_test_number;
                }
            }
            else {
                $last_test_name = "";
            }
        }
        elsif (
/^\s*(\xE2\x9C\x94\xEF\xB8\x8F|\xF0\x9F\x92\xA3)\s*(Passed|Failed):\s*(.+?)\s*$/
          )
        {
            my $n = $2;
            my $v = $3;
            $n =~ s/^\s+|\s+$//g;    # trim leading and trailing spaces
            $v =~ s/^\s+|\s+$//g;
            $last_test_results .= "$n: $v\n";
        }
        else {
            push @current_results_leftovers, $_;
        }
    }

    if ( length($last_test_name) > 0 ) {
        $current_results_subtests{$last_test_name} .= $last_test_results;
    }
}

my $contents_line = read_file( $filename_first, { binmode => ':raw', atomic => 1 } );
process_file_contents($contents_line); undef $contents_line;
my %results_first_subtests = %current_results_subtests; undef %current_results_subtests;
my %results_first_sequences = %current_results_sequences; undef %current_results_sequences;
my @results_first_leftovers = @current_results_leftovers; undef @current_results_leftovers;

$contents_line =
  read_file( $filename_second, { binmode => ':raw', atomic => 1 } );
process_file_contents($contents_line);
undef $contents_line;

my %results_second_subtests = %current_results_subtests; undef %current_results_subtests;
my %results_second_sequences = %current_results_sequences; undef %current_results_sequences;
my @results_second_leftovers = @current_results_leftovers; undef @current_results_leftovers;

my $count_first  = scalar keys %results_first_subtests;
my $count_second = scalar keys %results_second_subtests;

my %results_primary_subtests;
my %results_secondary_subtests;
my %results_primary_sequences;
my %results_secondary_sequences;
my $filename_primary_input;
my $filename_secondary_input;
my @results_primary_leftovers;
my @results_secondary_leftovers;

if ( $count_second > $count_first ) {
    %results_primary_subtests    = %results_second_subtests;
    %results_secondary_subtests  = %results_first_subtests;
    %results_primary_sequences   = %results_second_sequences;
    %results_secondary_sequences = %results_first_sequences;
    @results_primary_leftovers   = @results_second_leftovers;
    @results_secondary_leftovers = @results_first_leftovers;
    $filename_primary_input      = $filename_second;
    $filename_secondary_input    = $filename_first;
}
else {
    %results_primary_subtests    = %results_first_subtests;
    %results_secondary_subtests  = %results_second_subtests;
    %results_primary_sequences   = %results_first_sequences;
    %results_secondary_sequences = %results_second_sequences;
    @results_primary_leftovers   = @results_first_leftovers;
    @results_secondary_leftovers = @results_second_leftovers;
    $filename_primary_input      = $filename_first;
    $filename_secondary_input    = $filename_second;
}

undef %results_first_subtests;
undef %results_second_subtests;
undef %results_first_sequences;
undef %results_second_sequences;
undef @results_first_leftovers;
undef @results_second_leftovers;

my $count_primary_subtests    = scalar keys %results_primary_subtests;
my $count_secondary_subtests  = scalar keys %results_secondary_subtests;
my $count_primary_sequences   = scalar keys %results_primary_sequences;
my $count_secondary_sequences = scalar keys %results_secondary_sequences;

print "Comparing set of tests from $filename_primary_input ($count_primary_subtests/$count_primary_sequences tests) with the set of tests from $filename_secondary_input ($count_secondary_subtests/$count_secondary_sequences tests)...\n";

my $identical = $true;
my @output_primary;
my @output_secondary;

foreach my $key (
    sort { $results_primary_sequences{$a} cmp $results_primary_sequences{$b} }
    keys %results_primary_sequences )
{
    my $value_primary;
    my $value_secondary;
    $value_primary =
      join( "\n", sort( split "\n", $results_primary_subtests{$key} ) );
    if ( exists( $results_secondary_subtests{$key} ) ) {
        $value_secondary =
          join( "\n", sort( split "\n", $results_secondary_subtests{$key} ) );

        if ( $value_primary eq $value_secondary ) {

            # lines are identical
        }
        else {

            push @output_primary,   $key;
            push @output_primary,   $value_primary;
            push @output_secondary, $key;
            push @output_secondary, $value_secondary;
            $identical = $false;
        }
    }
    else {
        push @output_primary,   $key;
        push @output_primary,   $value_primary;
        push @output_secondary, $key;
        $identical = $false;
    }
}

if ( $identical == $true ) {
    print "The two sets of tests are identical.\n";
}
else {
    my $filename_primary_output      = $filename_primary_input . ".out";
    my $filename_secondary_output    = $filename_secondary_input . ".out";
    my $filename_primary_leftovers   = $filename_primary_input . ".leftovers";
    my $filename_secondary_leftovers = $filename_secondary_input . ".leftovers";
    print
"Writing the abbreviated test results to $filename_primary_output (primary) and $filename_secondary_output (secondary)...\n";
    my $output_string_primary = join( "\n", @output_primary ); undef @output_primary;
    my $output_string_secondary = join( "\n", @output_secondary );  undef @output_secondary;
    write_file( $filename_primary_output, { binmode => ':raw', atomic => 1 }, $output_string_primary );  undef $output_string_primary;
    write_file( $filename_secondary_output, { binmode => ':raw', atomic => 1 }, $output_string_secondary ); undef $output_string_secondary;
    my $leftovers_string_primary = join( "\n", @results_primary_leftovers ); undef @results_primary_leftovers;
    my $leftovers_string_secondary = join( "\n", @results_secondary_leftovers ); undef @results_secondary_leftovers;
    print "Writing the leftovers to $filename_primary_leftovers and $filename_secondary_leftovers...\n";
    write_file( $filename_primary_leftovers, { binmode => ':raw', atomic => 1 }, $leftovers_string_primary ); undef $leftovers_string_primary;
    write_file( $filename_secondary_leftovers, { binmode => ':raw', atomic => 1 }, $leftovers_string_secondary ); undef $leftovers_string_secondary;
    print "Done.\n";
}
