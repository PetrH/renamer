#!/usr/bin/perl
#
# Renamer
#
# Advance formatting script for downloaded TV shows.
#
# Copyright (C) 2013-2014  Petr Havlicek (ph@petrh.cz)
#
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	any later version.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.
#
#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <http://www.gnu.org/licenses/>.

use 5.010;
use strict;
use warnings;
use File::Copy;

if ( !chdir $ARGV[0] ) {
  print "Change to " . $ARGV[0] . " has failed!";
  exit;
}

my @dirs = split "/", $ARGV[0];
my $show_name = $dirs[-1];

# Decompress RAR Files
# if (/\.rar$/) {
#     say "Decompress $_";
#     my @tmp = `unrar e $_`;
# }

# Load names.csv
my $file = "names.csv";
my $names;

if ( -e $file ) {

  open( my $fh, '<', $file ) or die "Could not open '$file' $!\n";

  while (<$fh>) {
    chomp $_;
    my @fields = split ";";
    $names->{ $fields[0] } = $fields[1];

  }

  close $fh;
}

# TODO Match more file types!!!!

my @files     = <*.mkv>;
my $extension = ".mkv";

for (@files) {
  ( my $episode = $_ ) =~ s/.*(\d)x(\d\d).*/$1x$2/g;
  my $session_number = $1;
  my $new_name;

  if ( defined $session_number ) {
    $new_name = "$show_name - $episode";
  }
  else {
    next;
  }

  if ( defined $names && defined $names->{$episode} ) {
    $new_name .= " - " . $names->{$episode};
  }

  $new_name .= $extension;
  say $new_name;

  # Rename and move to correct direcotry
  if ( !-d "./Session " . $session_number ) {
    my $created = mkdir "./Session " . $session_number;
    move $_, "./Session " . $session_number . "/" . $new_name if $created;
  }
  else {
    move $_, "./Session " . $session_number . "/" . $new_name;
  }
}
