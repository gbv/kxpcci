#!/usr/bin/env perl
use v5.14;
use JSON::PP;
use URI::Escape;

# create a list from list of notations

my $list = {
    prefLabel => { de => 'RVK-BK Top 250' },
    scopeNote => {
        de => ['Häufigste RVK-Notationen in K10plus wenn keine BK vorhanden']
    },
    concepts => []
};

while (<>) {
    chomp;
    push @{ $list->{concepts} },
      {
        url      => "http://rvk.uni-regensburg.de/nt/" . uri_escape($_),
        notation => [$_],
        inScheme => [ { uri => "http://uri.gbv.de/terminology/rvk/" } ]
      };
}

say JSON::PP->new->pretty->encode($list);
