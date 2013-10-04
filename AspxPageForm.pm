package AspxPageForm;

use Mojo::Base -base;

use Mojo::UserAgent;

has 'ua' => sub { Mojo::UserAgent->new };

has 'start_url';
has 'start_tx';
has 'form_eles';
has 'form_action';

sub new { 
	my( $class, $url ) = @_;

	my $self = bless {}, $class;
	$self->start_url( $url );


	my $tx = $self->ua->get( $url );
	$self->start_tx( $tx );

	unless( $tx->success ) { 
		die "Error [$url]: ", (join " ", $tx->error), "\n";
	}

	my $aspform = $tx->res->dom->at("form[name=aspnetForm]");
	$self->form_action( Mojo::URL->new( $aspform->{action} )->to_abs( Mojo::URL->new( $url ) ) );

	$self->form_eles( {  @{ $aspform->find('input')->map(sub{ $_->{name}, $_ }) }  } );

	return $self;
}

sub click {
	my( $self, $name, $extra_fields ) = @_;

	my %submit_data;
	
	if( $self->form_eles->{$name} ) {
		$submit_data{ $name } = $self->form_eles->{$name}->{value};
	}
	else {
		die "Failed to find input element [$name]\n";
	}

	for my $ele ( values %{ $self->form_eles } ) { 
		$submit_data{ $ele->{name} } = $ele->{value} unless lc $ele->{type} eq 'submit';
	}

	if( $extra_fields ) { 
		for( keys %$extra_fields ) { $submit_data{ $_ } = $extra_fields->{$_} }
	}

	my $new_tx = $self->ua->build_tx( POST => $self->form_action => form => \%submit_data );

	my $form_tx = $self->ua->start( $new_tx );

	return $form_tx;
}

sub submit_button_names {
	my( $self ) = @_;

	return map $_->{name}, grep lc $_->{type} eq 'submit', values %{ $self->form_eles };
}

1;
