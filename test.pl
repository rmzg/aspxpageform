
use strict;
use warnings;

use AspxPageForm;

my $page = AspxPageForm->new( 'http://www.hcdistrictclerk.com/Common/e-services/PublicDatasets.aspx' );

my( $download_button_name ) = grep /buttonDownload/, $page->submit_button_names;

my $tx = $page->click( $download_button_name, { hiddenDownloadFile => 'Criminal\\2012-12-21 OVERVIEW.pdf' } );

print $tx->res->build_headers;
