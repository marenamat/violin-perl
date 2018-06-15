#!/usr/bin/perl

use lib '.';
use Violin;

#my @data = ( 311, 312, 313, 312, 314, 314.5, 315, 318, 324);

open F, "violin_data.csv" or die $!;
my @data = (<F>);
map { chomp $_; } @data;

#Violin->plot("violin-test.png", @data);
Violin->gnuplot("violin-test.png", @data);
