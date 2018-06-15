#!/usr/bin/perl

package Violin;

use Chart::Gnuplot;

sub func {
  my $where = shift;
  my $mul = shift;
  my $var = shift;
  return "($mul*exp((-(t-($where))**2)/(2))/sqrt(2*pi))";
}

sub dataset {
  my $args = shift;
  my $n = shift;
  my @data = ($n > 1) ? @_[(@_/$n)..((($n-1)*(@_+1))/$n)] : @_;
  return (
    Chart::Gnuplot::DataSet->new(
      func => {
	x => (join "+", map { func($_, ($n-2)/($n*@_)) } @data),
	y => "t"
      },
      %$args,
    ),
    Chart::Gnuplot::DataSet->new(
      func => {
	x => "-(" . (join "+", map { func($_, ($n-2)/($n*@_)) } @data) . ")",
	y => "t"
      },
      %$args,
    ),
  );
}

sub gnuplot {
  my $class = shift;
  my $file = shift;

  @_ = sort { $a <=> $b } @_;

  my $max = $_[@n-1];
  my $min = $_[0];

  my $sum = 0;
  my $qsum = 0;
  foreach (@_) {
    $qsum += $_**2;
    $sum += $_;
  }

  my $mean = $sum / @_;
  my $var = $qsum/@_ - $mean**2;
  my $sd = sqrt($var);

  my @trange = ($min-$sd, $max+$sd);
  my @xrange = ( -0.1, 0.1 );

  my $chart = Chart::Gnuplot->new(
    output => $file,
    xrange => [ @xrange ],
    yrange => [ @trange ],
    trange => [ @trange ],
    tmargin => 0,
    bmargin => 0,
    imagesize => "0.6, 2",
    xtics => undef,
  );

  my $n = scalar @_;
  $chart->plot2d(
    dataset( {
	width => 2,
	color => '#000000',
      }, 1, @_ ),
    (( @_ >= 4 ) ? (
	dataset( {
	    width => 4,
	    color => '#666666',
	  }, 4, @_ ),
      ) : ()),
    (( @_ >= 10 ) ? (
	dataset( {
	    width => 4,
	    color => '#000000',
	  }, 10, @_ )
      ) : ()),
    Chart::Gnuplot::DataSet->new(
      points => [[0, $mean]],
      pointtype => 7,
      pointsize => 1,
      color => '#000000',
    ),
    ( map {
      Chart::Gnuplot::DataSet->new(
      func => { y => "$mean+$sd*($_)", x => "1-2*(t-$trange[0])/($trange[1]-$trange[0])" },
      width => 0.5,
      color => '#884400',
      ) } map { ($_, -$_) } (1, 2, 3)),
 );

}

42;
