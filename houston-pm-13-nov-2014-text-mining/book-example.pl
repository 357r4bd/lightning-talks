#!/usr/bin/perl

use strict;
use warnings;

#
# B. Estrade <estrabd@gmail.com>
# 13 Nov. 2014 Houston Perl Mongers
# This code is a direct modification of the Example in Section 5.7
# of Text Mining With Perl by Roger Bilisoly; it's a lot more sophisticated
# than directly using the Cosine method for comparison.
#

$/ = undef;

my $data = <DATA>;

rank( $data, 0 );

# clean up text for analysis
sub clean {
    my $text = shift;
    $text = lc $text;
    $text =~ s/the |of |and |\-|#|'s|"|!|\(|\)|\?//gi;
    $text =~ s/,|&/ /gi;
    $text =~ s/ +/ /gi;
    $text =~ s/ii/i/gi;
    $text =~ s/--/ /g;                 # Remove dashes
    $text =~ s/ - / /g;                # Remove dashes
    $text =~ s/[,.";!()?:_\[\]]//g;    # Remove non-apostrophes
    $text =~ s/\s+/ /g;                # Replace multiple spaces with one space
    $text =~ s/^\s+//g;                # Remove spaces at the start of a line
    return $text;
}

# one huge sub to do all necessary steps
sub rank {
    my $data = shift;
    my $show = shift;

    # all lowercase
    $data = $data;

    #remove stop words and symbols

    my @titles = split /\n/, $data;
    my $original = $titles[$show];

    @titles = map { clean($_); } @titles;

    my @tf        = ();
    my %granddict = ();
    my $ntitle    = 0;
    foreach my $t (@titles) {
        my @words = split / /, $t;
        foreach my $word (@words) {
            ++$tf[$ntitle]->{$word};
            ++$granddict{$word};
        }
        ++$ntitle;
    }

    my %df = ();

    # Step 2: Compute the document frequencies
    foreach my $word ( sort keys %granddict ) {
        my $sum = 0;
        for my $i ( 0 .. $#tf ) {
            if ( exists $tf[$i]->{$word} and $tf[$i]->{$word} > 0 ) {
                ++$sum;
            }
            $df{$word} = $sum;
        }
    }

    # Step 3: Compute the tf-idf weights
    my @weight = ();
    my $n      = @tf;    # number of stories
    foreach my $word ( sort keys %granddict ) {
        for my $i ( 0 .. $#tf ) {
            $weight[$i]->{$word} = ( exists $tf[$i]->{$word} ) ? $tf[$i]->{$word} * log( $n / $df{$word} ) / log(2) : 0;
        }
    }

    # Step 4: Normalize the columns of weights
    my @unit = ();
    for my $i ( 0 .. $#tf ) {
        my $len2 = 0;
        foreach my $word ( sort keys %granddict ) {
            $len2 += $weight[$i]->{$word}**2;
        }
        my $len = sqrt($len2);
        foreach my $word ( sort keys %granddict ) {
            $unit[$i]->{$word} = $weight[$i]->{$word} / $len;
        }
    }

    # Step 5: Compute cosine similarities between each pair of stories
    my @cosine = ();
    for my $i ( 0 .. $#tf ) {
        for my $j ( 0 .. $#tf ) {
            my $sum = 0;
            foreach my $word ( sort keys %granddict ) {
                $sum += $unit[$i]->{$word} * $unit[$j]->{$word};
            }
            $cosine[$i][$j] = $sum;
        }
    }

=pod
    # output entire matrix
    for my $i ( 0 .. $#tf ) {
        print qq{Title of item $i - "$titles[$i]"\n};
    }

    # Print out the cosine similarities
    print "\n";
    for my $i ( 0 .. $#tf ) {
        for my $j ( 0 .. $#tf ) {
            printf "%.4f ", $cosine[$i][$j];
        }
        print "\n";
    }
=cut

    my $h = {};
    my $c = 0;
    foreach my $i ( @{ $cosine[$show] } ) {
        $h->{ $titles[ $c++ ] } = $i;
    }

    my @k = sort { $h->{$b} <=> $h->{$a} } keys(%$h);

    printf( "Original: %s\n", $original );
    foreach my $t (@k) {
        printf( "[%0.9f] - %s\n", $h->{$t}, $t );
    }

    return;
}

__DATA__
Cool Boy Scout Patch - Black Hole Patrol! (#288)
BSA Event Patch 1977 Yapping Tree Hoover Day Camp MINT
BSA Event Patch 1977 Buckeye Council Cub Day Camp MINT
BSA Event Patch 1979 Green Mountain Council (skiing) Polar Bear MINT
BSA 75th Anniversary Diamond Jubilee Old Colony Council Camporee 1985 MINT
Vintage Boy Scouts of America Scout Sign Hand Pin
Cool Boy Scout Patch - Striking Viper Patrol! (#331)
Vintage Official Cub Scout Binoculars in Original Box
2 CUB SCOUT PINEWOOD DERBY 1988 PATCH NORTHEAST ILLINOIS COUNCIL LAKES DISTRICT
CUB SCOUT CAMPING PATCH SUPER 88 SOUTHEAST WISCONSIN COUNCIL
CUB SCOUT BOWL A THON 1992 PATCH NORTHEAST ILLINOIS COUNCIL
CUB SCOUT BOWL A THON 1993 PATCH NORTHEAST ILLINOIS COUNCIL
Cool Boy Scout Patch - Snipe Patrol! (#330)
SELECT,PRIMO TAGLIO,MFG,COMPANY,RARE,COLLECT PATCH
ABTA SPRINGS,COMPANY RARE COLLECTABLE PATCH
FRONTIER ROUNDUP ,BOY SCOUTS OF AMERICA BSA PATCH
USA OLYMPIC TEAM GOOD TURN B.S.A.RARE SPORTS PATCH
OVER THE TOP N.C.H.A. 1969 MONEY FOR SCHOLAR'S PATCH
VINTAGE BOY SCOUT CAMP PATCH - CAMP BUCOCO - LOT 24
VINTAGE BOY SCOUT CAMP PATCH PATCH - CAMP AGAWAM - LOT 24
VINTAGE BOY SCOUT CAMP PATCH PATCH - ALLEGHEY SCOUT CAMPS - LOT 24
6" YUKI NATION PINEWOOD DERBY 1996 TROPHY
Explorer 1960s Dark Green Pants, Waist 30, Inseam 30     eb04 #3
Vintage Copper Military Canteen with Large Cross
Boy Scout Pants, Elastic Waist, Size 16 Waist 28    eb04 #5
2003 World Jamboree Troop 12 lined Nylon Jacket     eb04
BOY SCOUT 1973 JAMBOREE SET - PATCHES & DECAL - FREE SHIPPING
VINTAGE BOY SCOUT  - 1960's CAMP NECKERCHIEF - CAMP COFFMAN STAFF - LOT 24
BOY SCOUT PATCH - 1960's CAMP AGAWAM - LAWRENCE COUNTY COUNCIL - LOT 24
VINTAGE BOY SCOUT  - 1960's CAMP NECKERCHIEF - ALLEGHENY SCOUT CAMPS - LOT 24
BOY SCOUT PATCH - 1960 CAMP LINWOOD HAYNE - GEORGIA-CAROLINA COUNCIL - LOT 24
BOY SCOUT PATCH - 1960's CREATER CLEVELAND COUNCIL SCOUT CAMPS - LOT 24
VINTAGE BOY SCOUT  - CAMP PATCH AND NECKERCHIEF - CAMP KIONDASHAWA - LOT 24
BOY SCOUT 1975 14th WORLD JAMBOREE PATCHES - FREE SHIPPING
BOY SCOUT 1971 13th WORLD JAMBOREE PATCH & NECKERCHIEF - FREE SHIPPING
BOY SCOUT 1967 WORLD JAMBOREE PATCH, NECKERCHIEF & STAMPS - FREE SHIPPING
BOY SCOUT 1973 JAMBOREE SET - PATCHES, DECAL & NECKERCHIEF - FREE SHIPPING
BOY SCOUT PATCH - 1960's WM. D BOYCE DISTRICT - LOT 24
BOY SCOUT PATCH - 1975 CAMPEX WEST - PRE JAMBO CONTINGENT? - FREE SHIPPING
Vintage Davy Crockett Iron On Emblem -  Original Card
Boy Scouts of America Fundraising Kit, 1955
Lot of 4, Boy Scout Patches, 2010, 100th Anniversary , GREAT CONDITION
Cool Boy Scout Patch - Hanging Around Patrol! (#316)
Vintage BOY SCOUTS Senior Patrol Celluloid Metal Neckerchief Tie Slide
LASALLE COUNCIL Boy Scout Patch 1OOth Anniv. Coucil Celebration, GREAT Con.
Cool Boy Scout Patch - Rainbow Trout Patrol! (#298)
Vintage Lot of Boy Scout Merit Badges Canada, World Jamboree, Contingent Patches
Boy Scouts Of America A Centennial History Sealed In Package  (629)
Cub Scout Handbook Cover Canvas Velcro Book Cover
VINTAGE BOY SCOUT MERIT BADGE
