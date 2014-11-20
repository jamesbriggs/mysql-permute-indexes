#!/usr/bin/perl

# Program: permute_indexes.pl
# Purpose: generate all permutations of index statements of up to 3 columns per table for complex queries
# Author: James Briggs
# Date: 2014 11 19
# Version: 0.1
# Env: perl5
# Example:
# $ permute_indexes.pl | tee permute_indexes.txt
#    alter table t1 add index idx_jb_001 (c1,c3);
#    alter table t1 add index idx_jb_002 (c1,c2,c3);
#    alter table t1 add index idx_jb_003 (c1,c3,c2);
#    [...]
#    alter table t2 add index idx_jb_007 (c4,c5);
#    [...]
# $ mysql -u root -p test <permute_indexes.txt
# mysql> explain select * from t1, t2 where c1=c4 and c1=? and c2=? and c3=? and c5=?;
# Table | Key
# --------------
# t1 | idx_jb_002
# t2 | idx_jb_007
#
# Notes:

use strict;
use diagnostics;

###
### Start of user settings
###

   # list all tables used in the query with up to 3 columns per table from
   #  the join and/or where clause you want to permute indexes for
   my %tables = (
      t1 => [ qw(c1 c2 c3) ],
      t2 => [ qw(c4 c5 c6) ],
   );

   # list tables with all pre-existing indexes here to not duplicate.
   # for multi-column indexes, comma-separate column names
   my %old_indexes = (
      t1 => [ 'c1', 'c1,c2', ],
      t2 => [ 'c4', ],
   );

###
### End of user settings
###

   my %seen_global;

   for my $t (sort keys %old_indexes) {
      for my $c (@{$old_indexes{$t}}) {
         $c =~ s/ +//g;
         $seen_global{$c} = 1 if defined $c;
      }
   }

   my $n=1;

   for my $t (sort keys %tables) {
      my $r=$tables{$t};
      push @{$r}, undef;
      for my $c1 (@{$r}) {
         for my $c2 (@{$r}) {
             for my $c3 (@{$r}) {
                my %seen_local;
                my @cols;

                for my $c (($c1, $c2, $c3)) {
                   if (defined $c and not exists $seen_local{$c}) {
                      push @cols, $c;
                      $seen_local{$c} = 1;
                    }
                }
   
                my $idx_col_names = join(',', @cols);
                next if $idx_col_names eq '' or $seen_global{$idx_col_names}++;
   
                print sprintf("alter table $t add index idx_jb_%03d ($idx_col_names);\n", $n++);
             }
         }
      }
   }

