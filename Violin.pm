#!/usr/bin/perl

package Violin;

use Cairo;

sub wc($$$$$$) {
  my ($cr, $x, $y, $text, $hpos, $vpos) = @_;
 
  $cr->save;
  my $te = $cr->text_extents($text);

  $cr->translate($x, $y);
  $cr->move_to(
    { L => 0,
      C => -$te->{width}/2,
      R => -$te->{width}
    }->{$hpos},
    { T => $te->{height},
      C => $te->{height}/2,
      B => 0
    }->{$vpos});
  $cr->text_path($text);
  $cr->fill;
  $cr->restore;
}

sub plot {
  my $class = shift;
  my $file = shift;
  my @data = @_;

  my $offset = 50;
  my $height = 100;
  my $steps = 10;
  my $width = 1000;
  my $height_total = 2*$offset + $height*$steps;
  my $surface = Cairo::ImageSurface->create('argb32', $width, $height_total);
  my $cr = Cairo::Context->create($surface);

  my $max;
  map { $max = ((defined $max) and $max > $_) ? $max : $_; } @data;

  my $order = int(log($max)/log($steps) + 1);
  my $omul = $steps**($order-1);
  my $opix = $omul / $height;

  $cr->set_font_size($height / 5);

  for (my $i=0; $i<=$steps; $i++) {
    $cr->move_to(0, $offset*(2*$i+1));
    $cr->line_to($width, $offset*(2*$i+1));
    $cr->stroke;

    wc($cr, 0, $offset*(2*$i+1), $omul*$i, 'L', 'C');
  }

  $cr->set_line_width(3);

  $cr->move_to($width/2, 0);
  $cr->line_to($width/2, $height_total);
  $cr->stroke;

  $surface->write_to_png($file);
}

42;
