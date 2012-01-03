#!/usr/bin/perl
# -----------------------------------------------------------------------
#  Program: diffdirs.pl
#  Revision: $Id: diffdirs.pl,v 1.2 2008/09/21 17:01:04 rosinski Exp $
#  Original code developed by Jim Rosinski
#                                                                        
#  This script compares 2 directory hierarchies.
# -----------------------------------------------------------------------
#  Copyright 1991-2005: Jim Rosinski
# -----------------------------------------------------------------------
#  License:                                                              
#   1. You are free to use this program and/or to redistribute           
#      this program.                                                     
#   2. You are free to modify this program for your own use,             
#      including commercial use.
#   3. Use of this program or creation of derived works based on this    
#      program constitutes acceptance of these licensing restrictions.   
#   4. Absolutely no warranty is expressed or implied.                   
# -----------------------------------------------------------------------

use strict;

my ($dir1);
my ($dir2);
my ($arg);

our ($verbose) = 0;
our ($one) = 0;
our ($two) = 0;
our ($suffix);
our ($ignore);

while ($arg = shift (@ARGV)) {
    if ($arg eq "-v") {
	$verbose = 1;
    } elsif ($arg eq "-1") {
	$one = 1;
    } elsif ($arg eq "-2") {
	$two = 1;
    } elsif ($arg eq "-s") {
	$suffix = shift (@ARGV);
	chomp ($suffix);
	print (STDOUT "Only checking files which end in $suffix\n");
    } elsif ($arg eq "-i") {
	$ignore = shift (@ARGV);
	chomp ($ignore);
	print (STDOUT "Ignoring files which end in $ignore\n");
    } else {
	if (! defined $dir1) {
	    $dir1 = $arg;
	} elsif (! defined $dir2) {
	    $dir2 = $arg;
	} else {
	    die_usemsg ("Unknown argument $arg\n");
	}
    }
}

(defined $dir1 && defined $dir2) || die_usemsg ("Must specify 2 directories\n");

diff_files ($dir1, $dir2);
exit 0;

sub diff_files {
    my ($dir1) = $_[0];
    my ($dir2) = $_[1];

    my ($file);
    my ($path1);
    my ($path2);
    my ($ret);
    my ($found);
    my ($i);

    our ($verbose);
    our ($one);
    our ($two);

    opendir (DIR1, $dir1) || die ("Can't open $dir1");
    opendir (DIR2, $dir2) || die ("Can't open $dir2");
    my (@allfiles1) = readdir (DIR1);
    my (@allfiles2) = readdir (DIR2);
    closedir (DIR1);
    closedir (DIR2);
#
# Compare plain files
#
    foreach $file (@allfiles1) {
	$path1 = "$dir1/$file";
	$path2 = "$dir2/$file";
#
# Check for "only compare" and "never compare" flags.
#
	next if (defined $suffix && $file !~ /$suffix$/);
	next if (defined $ignore && $file =~ /$ignore$/);
	if (-f $path1) {
	    if (-f $path2) {
		$ret = `diff -w $path1 $path2`;
		if ($ret == 0) {
		    print (STDOUT "$path1 matches\n$path2\n\n") if ($verbose);
		} else {
		    print (STDOUT "$file in\n$dir1\ndiffers from\n$dir2\n");
		    if ($verbose) {
			print (STDOUT "diff -w $path1 $path2:\n");
			system ("diff -w $path1 $path2");
			print (STDOUT "Hit <ENTER> to continue\n");
			<STDIN>;
		    }
		}
	    } else {
		print (STDOUT "$path2 does not exist\n\n");
	    }
	}
    }
#
# Report files which exist in one dir but not the other
#
    if ($one) {
	foreach $file (@allfiles1) {
#
# If asked to only compare files which end in a particular suffix,
# skip those which don't meet the criteria.
#
	    next if (defined $suffix && $file !~ /$suffix$/);
	    $found = 0;
	    for ($i = 0; $i < $#allfiles2; $i++) {
		if ($file eq $allfiles2[$i]) {
		    $found = 1;
		    last;
		}
	    }
	    if (! $found) {
		print (STDOUT "$file exists in $dir1 but not in $dir2\n\n");
	    }
	}
    }

    if ($two) {
	foreach $file (@allfiles2) {
#
# If asked to only compare files which end in a particular suffix,
# skip those which don't meet the criteria.
#
	    next if (defined $suffix && $file !~ /$suffix$/);
	    $found = 0;
	    for ($i = 0; $i < $#allfiles1; $i++) {
		if ($file eq $allfiles1[$i]) {
		    $found = 1;
		    last;
		}
	    }
	    if (! $found) {
		print (STDOUT "$file exists in $dir2 but not in $dir1\n\n");
	    }
	}
    }
#
# Recursively compare directories
#
    foreach $file (@allfiles1) {
	if ($file ne "." && $file ne "..") {
	    $path1 = "$dir1/$file";
	    $path2 = "$dir2/$file";
	    if (-d $path1 && -x $path1) {
		if (-d $path2 && -x $path2) {
		    diff_files ($path1, $path2);
		} else {
		    print (STDOUT "$path1 exists but\n$path2 does not\n\n");
		}
	    }
	}
    }
    return 0;
}

sub die_usemsg {
    defined $_[0] && print (STDOUT "$_[0]");
    print (STDOUT "Usage: $0 [-s suffix] [-v] [-1] [-2] dir1 dir2\n",
	   " -s suffix => only compare files ending in <suffix>\n",
	   " -i suffix => never compare files ending in <suffix>\n",
	   " -v        => verbose: show diffs and stop on each file with non-zero diffs\n",
	   " -1        => list files only in first dir hierarchy\n",
	   " -2        => list files only in second dir hierarchy\n");
    exit 1;
}
