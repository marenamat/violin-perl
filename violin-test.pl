#!/usr/bin/perl

use lib '.';
use Violin;

my @data = (
  1,2,4,5,8
);

Violin->plot("violin-test.png", @data);
