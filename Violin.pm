#!/usr/bin/perl

package Violin::DataSet;

use Moose;

has 'data' => (
  is => 'rw',
  isa => 'ArrayRef[Num]',
  required => 1,
);

sub atd($$) {
  has $_[0] => ( is => 'rw', isa => 'Num', lazy => 1, default => $_[1] );
}

atd('n', sub { scalar @{$_[0]->data}; });
atd('min', sub { $_[0]->data->[0]; });
atd('max', sub { $_[0]->data->[$_[0]->n - 1]; });
atd('sum', sub { my $s = 0; $s += $_ foreach (@{$_[0]->data}); $s; });
atd('qsum', sub { my $s = 0; $s += $_**2 foreach (@{$_[0]->data}); $s; });
atd('mean', sub { $_[0]->sum / $_[0]->n; });
atd('var', sub { $_[0]->qsum / $_[0]->n - $_[0]->mean**2; });
atd('sd', sub { sqrt($_[0]->var); });
atd('minrange', sub { $_[0]->min - $_[0]->sd; });
atd('maxrange', sub { $_[0]->max + $_[0]->sd; });
atd('width', sub { 1.25 / sqrt($_[0]->n); });

sub BUILD {
  my ($self) = @_;

  $self->data([ sort { $a <=> $b } @{$self->data}  ]);
}

sub func {
  my $where = shift;
  my $mul = shift;
  my $var = shift;
  return "($mul*exp((-(t-($where))**2)/(2*$var))/sqrt(2*pi))";
}

sub dataset {
  my $self = shift;
  my $pos = shift;
  my $args = shift;
  my $n = shift;

  my @alldata = @{$self->data};
  my @data = ($n > 1) ? @alldata[(@alldata/$n)..((($n-1)*(@alldata+1))/$n)] : @alldata;

  return (
    Chart::Gnuplot::DataSet->new(
      func => {
	x => (join "+", $pos, map { func($_, ($n-2)/($n*@alldata), $self->var/@alldata) } @data),
	y => "t"
      },
      %$args,
    ),
    Chart::Gnuplot::DataSet->new(
      func => {
	x => $pos . "-(" . (join "+", map { func($_, ($n-2)/($n*@alldata), $self->var/@alldata) } @data) . ")",
	y => "t"
      },
      %$args,
    ),
  );
}

sub plot {
  my ($self, $chart, $pos, $trangemin, $trangemax) = @_;
  
  $pos += $self->width / 2;

  my @sdcoef = ( $self->width / ($trangemax - $trangemin),);
  push @sdcoef, $pos - ($trangemax + $trangemin) * $sdcoef[0] / 2;

  return (
    # All points
    $self->dataset( $pos, {
	width => 2,
	color => '#000000',
      }, 1),
    # 10->90 percentile
    (( @{$self->data} >= 10 ) ? (
	$self->dataset( $pos, {
	    width => 4,
	    color => '#000000',
	  }, 10)
      ) : ()),
    # 25->75 percentile
    (( @{$self->data} >= 4 ) ? (
	$self->dataset( $pos, {
	    width => 4,
	    color => '#666666',
	  }, 4),
      ) : ()),
    # Mean point
    Chart::Gnuplot::DataSet->new(
      points => [[$pos, $self->mean]],
      pointtype => 7,
      pointsize => 1,
      color => '#000000',
    ),
    # Standard deviations from mean
    ( map {
      Chart::Gnuplot::DataSet->new(
      func => {
	y => $self->mean . "+" . $self->sd . "*($_)",
	x => "$sdcoef[0]*t + $sdcoef[1]",
      },
      width => 1,
      color => '#444444',
      ) } map { ($_, -$_) } (1, 2, 3)),
 );
}

package Violin;

use Chart::Gnuplot;

sub gnuplot {
  my $class = shift;
  my $file = shift;

  my ($minrange, $maxrange) = ($_[0]->minrange, $_[0]->maxrange);
  my $maxpos = 0;
  foreach (@_) {
    $minrange = $_->minrange if ($_->minrange < $minrange);
    $maxrange = $_->maxrange if ($_->maxrange > $maxrange);
    $maxpos += $_->width;
  }

  my @trange = ($minrange, $maxrange);
  my @xrange = ( 0, $maxpos );

  my $chart = Chart::Gnuplot->new(
    output => "$file",
    xrange => [ @xrange ],
    yrange => [ @trange ],
    trange => [ @trange ],
    tmargin => 0,
    bmargin => 0,
    imagesize => (0.6*@_) . ", 2",
    xtics => undef,
  );

  my @datasets;
  my $curpos = 0;
  foreach (@_) {
    push @datasets, ($_->plot($chart, $curpos, @trange));
    $curpos += $_->width;
  }

  $chart->plot2d(@datasets);
}

42;
