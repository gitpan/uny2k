package uny2k;

use vars qw($VERSION);
$VERSION = '19.100';

use fields qw(_Year _Reaction);

require Carp;

use overload '+' => \&add,
             '%' => \&mod,
             ''  => \&stringize,
             '0+'=> \&numize,
             'fallback' => 'TRUE';

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;
    my($year, $reaction) = @_;
    
    my $self;
    {
        no strict 'refs';
        $self = [\%{$class.'::FIELDS'}];
    }
    $self->{_Year} 	= $year;
    $self->{_Reaction}	= $reaction || 'die';

    return bless $self => $class;
}


sub stringize {
    return shift->{_Year};
}


sub numize {
    return shift->{_Year};
}


sub _mk_localtime {
    my($reaction) = shift;
	
    return sub {
        return @_ ? localtime(@_) : localtime() unless wantarray;
        my @t = @_ ? localtime(@_) : localtime();
        $t[5] = __PACKAGE__->new($t[5], $reaction);
        @t;
    }
}

sub _mk_gmtime {
    my($reaction) = shift;
    
    return sub {
        return @_ ? gmtime(@_) : gmtime() unless wantarray;
        my @t = @_ ? gmtime(@_) : gmtime();
        $t[5] = __PACKAGE__->new($t[5], $reaction);
        @t;
    }
}


sub import {
    () = shift;	# Dump the package.
    my $reaction = shift;
    my $caller = caller;
	
    $reaction = ':DIE' unless defined $reaction;
    
    $reaction = $reaction eq ':WARN' ? 'warn' : 'die';
	
    {
        no strict 'refs';
        *{$caller . '::localtime'} 	=	&_mk_gmtime($reaction);
        *{$caller . '::gmtime'}		=	&_mk_gmtime($reaction);
    }
}

sub add {
    my($self, $a2) = @_;

    if( $a2 == 1900 ) {
        Carp::carp("Possible y2k fix found!  Unfixing.");
        return 19 . $self->{_Year};
    }
    else {
        return $self->{_Year} + $a2;
    }
}

sub mod {
    my($self, $modulus) = @_;

    if( $modulus == 100 ) {
        Carp::carp("Possible y2k fix found!  Unfixing.");
        return $self->{_Year};
    }
    else {
        return $self->{_Year} % $modulus;
    }
}
    
sub concat {
    my($self, $a2, $rev) = @_;

    if ($rev) {
    	return $a2 . $self->{_Year};
    } else {
    	return $self->{_Year} . $a2;
    }

    return $self->{_Year};
}

1;

=pod

=head1 NAME

uny2k - Removes y2k fixes

=head1 SYNOPSIS

  use uny2k;

  $year = (localtime)[5];
  printf "In the year %d, computers will everything for us!\n", 
      $year += 1900;

=head1 DESCRIPTION

Y2K has come and gone and none of the predictions of Doom and Gloom
came to past.  As the crisis is over, you're probably wondering why
you went through all that trouble to make sure your programs are "Y2K
compliant".  uny2k.pm is a simple module to remove the now unnecessary
y2k fixes from your code.

Y2K was a special case of date handling, and we all know that special
cases make programs more complicated and slower.  Also, most Y2K fixes
will fail around 2070 or 2090 (depending on how careful you were when
writing the fix) so in order to avert a future crisis it would be best
to remove the broken "fix" now.

uny2k will remove the most common y2k fixes in Perl:

    $year = $year + 1900;

and

    $two_digit_year = $year % 100;

It will change them back to their proper post-y2k values, 19100 and
100 respectively.

=head1 AUTHOR

Michael G Schwern <schwern@pobox.com> 
with apologies to Mark "I am not ominous" Dominous for further abuse 
of his code.

=head1 SEE ALSO

y2k.pm, D'oh::Year

=cut
