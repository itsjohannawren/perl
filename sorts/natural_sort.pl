#!/usr/bin/perl

use warnings;
use strict;

sub natural_sort ($$) {
	# Natural Sort by Jeff Walter <jeff@404ster.com>
	#
	# WARNING! This function makes horrific use of regular expressions (I know, I know). You've been warned.
	# Also, qr//'ing all of the regexes actually makes the routine 2x slower. WTF Perl?
	#
	# Call via `ARRAY = sort natural_sort ARRAY;`

	my ($a, $b) = @_;
	my ($aPart, $bPart, $aClass, $bClass);

	# Handle sorting undefs
	return (-1) if (! defined ($a) && defined ($b));
	return (1) if (defined ($a) && ! defined ($b));
	return (0) if (! defined ($a) && ! defined ($b));

	# Quickly bail if the values are the same
	return (0) if ($a eq $b);

	for (;;) {
		# Reset $aPart and $bPart
		($aPart, $bPart) = (undef, undef);

		# Grab the first group of liked-class bytes from each string
		$aPart = $1 if ($a =~ /^([0-9]+|[a-zA-Z]+|[^a-zA-Z0-9]+)?/);
		$bPart = $1 if ($b =~ /^([0-9]+|[a-zA-Z]+|[^a-zA-Z0-9]+)?/);

		# If one or both strings fail to match (are now empty) return the sort
		# This is the end condition
		return (-1) if (! defined ($aPart) && defined ($bPart));
		return (1) if (defined ($aPart) && ! defined ($bPart));
		return (0) if (! defined ($aPart) && ! defined ($bPart));

		if ($aPart ne $bPart) {
			# Store the class of A using a value we'll compare later
			$aClass = 0 if ($aPart =~ /^[0-9]+$/);
			$aClass = 1 if ($aPart =~ /^[a-zA-Z]+$/);
			$aClass = 2 if ($aPart =~ /^[^a-zA-Z0-9]+$/);
			# Store the class of B using a value we'll compare later
			$bClass = 0 if ($bPart =~ /^[0-9]+$/);
			$bClass = 1 if ($bPart =~ /^[a-zA-Z]+$/);
			$bClass = 2 if ($bPart =~ /^[^a-zA-Z0-9]+$/);

			if ($aClass < $bClass) {
				# A has a lower class than B
				return (-1);

			} elsif ($aClass > $bClass) {
				# A has a higher class than B
				return (1);

			} elsif ($aClass == 0) {
				# Digits sort by numeric value (integer, not float)
				return (-1) if ($aPart < $bPart);
				return (1) if ($aPart > $bPart);
				# Numeric values are the same so string sort
				return (-1) if ($aPart lt $bPart);
				return (1) if ($aPart gt $bPart);

			} elsif ($aClass == 1) {
				# Letters sort with string comparison, but it's case-insensitive
				($aPart, $bPart) = (lc ($aPart), lc ($bPart));
				return (-1) if ($aPart lt $bPart);
				return (1) if ($aPart gt $bPart);

			} elsif ($aClass == 2) {
				# Non-letter and Non-digit sort with string comparison
				return (-1) if ($aPart lt $bPart);
				return (1) if ($aPart gt $bPart);
			}
		}

		# Trim off the bit we just munched on
		$a = substr ($a, length ($aPart));
		$b = substr ($b, length ($bPart));
	}
}
