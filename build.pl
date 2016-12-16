#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use File::Path qw(make_path);

#TODO use a FUSE
#TODO and/or use only "nice" subset of the data

my $filename   = 'stripped';
my $filename_a = 'names';
my $max        = 10;           # how deep we want to go

my $max_len_dirname           = 255;
my $truncate_too_long_numbers = 1;

#to not get all
my $only_n_seq = 1024;

my $data = get_data( $filename, $max );
my $A_names = get_a_names($filename_a);

#print Dumper $data;

my $target = "oeis";
create_dir_and_files( $target, $data );

exit 0;

################################################################################
## subs ########################################################################
################################################################################

sub get_data {
    my $filename = shift;
    my $max      = shift;
    my %final;

    open( my $fh, '<:encoding(UTF-8)', $filename )
      or die "Could not open file '$filename' $!";

    my $i = 0;

    while ( my $row = <$fh> ) {
        $i++;
        last if $i > $only_n_seq;

        chomp $row;
        next if $row =~ '^#';

        my @s = split( ",", $row, $max + 2 );

        my $A = shift @s;

        $A =~ s/ //g;

        pop @s;

        if ( scalar(@s) == 0 ) {
            print "skip empty $A\n";
            next;
        }

        my $pointer = \%final;
        my $skip    = 0;

        foreach my $n (@s) {

            if ( $truncate_too_long_numbers and length($n) > $max_len_dirname )
            {
                print "skip $n\n";
                last;
            }
            $pointer->{$n} = {} if ( not defined $pointer->{$n} );
            $pointer = $pointer->{$n};
        }
        push( @{ $pointer->{'x'} }, $A );
    }
    return \%final;
}

sub get_a_names {
    my $filename = shift;
    my %names;

    open( my $fh, '<:encoding(UTF-8)', $filename )
      or die "Could not open file '$filename' $!";

    while ( my $row = <$fh> ) {
        chomp $row;
        next if $row =~ '^#';
        my ( $name, $long ) = split( / /, $row, 2 );
        $names{$name} = $long;
    }
    return \%names;
}

sub create_dir_and_files {
    my $root = shift;
    my $data = shift;

    foreach my $node ( keys %{$data} ) {
        if ( $node eq "x" ) {
            if ( scalar @{ $data->{$node} } > 1 ) {

                #more than one
            }

            #print "create: $root with: \n";

            make_path($root);
            foreach my $A ( @{ $data->{$node} } ) {
                open( my $fh, '>', "$root/$A.md" );
                print $fh "http://oeis.org/$A\n";
                print $fh "\n";
                print $fh $A_names->{$A} . "\n";
                close $fh;
            }

            #print Dumper $data->{$node};
        }
        else {
            create_dir_and_files( $root . "/$node", $data->{$node} );
        }
    }
}
