#!/usr/bin/env perl
use strict;
use warnings;

use MojoX::ASPXPageForm;

my $page = MojoX::ASPXPageForm->new( 'http://www.hcdistrictclerk.com/Common/e-services/PublicDatasets.aspx' );

my( $download_button_name ) = grep /buttonDownload/, $page->submit_button_names;


mkdir "ds";chdir "ds" or die $!;

for( @{ $page->dom->find('a') } ) {
	next unless $_->{onclick} and $_->{onclick} =~ /DownloadDoc\('([^\)]+)'\)/;

	my $path = $1;
	$path =~ s/\\\\/\\/g;

	print "$path\n";

	my $tx = $page->click( $download_button_name, { hiddenDownloadFile => $path } );

	print $tx->res->build_headers;

	my $filename = $path; $filename =~ s{/|\\}{_}g;

	open my $fh, ">", $filename or die "Failed to open >[$filename]: $!\n";

	print $fh $tx->res->body;

	sleep(10);
}

