#!/usr/bin/env perl
use v5.14;
use Catmandu -all;
use URI::Escape;
use HTTP::Tiny;
use JSON::PP;

# get list of notations
my $rvknobk = importer( 'CSV', file => 'rvk-no-bk-top120.csv' )->to_array;

# open file for update
my $csv = exporter(
    'CSV',
    file   => 'rvk-no-bk-top120.csv',
    fields => [qw(notation prefLabel cocoda)]
);
for my $rvk (@$rvknobk) {
    my $notation = $rvk->{notation};
    my $uri      = "http://rvk.uni-regensburg.de/nt/" . uri_escape($notation);

    if ( !$rvk->{prefLabel} ) {
        my $url = "https://coli-conc.gbv.de/rvk/api/data?notation="
          . uri_escape($notation);
        my $res = HTTP::Tiny->new->get($url);
        if ( $res->{success} ) {
            my $jskos = decode_json( $res->{content} );
            if (@$jskos) {
                $rvk->{prefLabel} = $jskos->[0]{prefLabel}{de};
            }
        }
    }

    $rvk->{cocoda} =
"https://coli-conc.gbv.de/cocoda/app/?fromScheme=http%3A%2F%2Furi.gbv.de%2Fterminology%2Frvk%2F&toScheme=http%3A%2F%2Furi.gbv.de%2Fterminology%2Fbk%2F&from="
      . uri_escape($uri);

    $csv->add($rvk);
}
