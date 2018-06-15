#!/usr/bin/perl

use lib '.';
use Violin;

#my @data = ( 311, 312, 313, 312, 314, 314.5, 315, 318, 324);

open F, "violin_data.csv" or die $!;
my @data = (<F>);
map { chomp $_; } @data;
my $dsa = Violin::DataSet->new(data => [ @data ]);
my $dsb = Violin::DataSet->new(data => [ map { $_ + (0.4 - rand) * 30 } @data ]);
my $dsc = Violin::DataSet->new(data => [ map { $_ + (0.6 - rand) * 30 } @data ]);

Violin->gnuplot("violin-test.png", $dsa, $dsb, $dsc);
