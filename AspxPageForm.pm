package AspxPageForm;

use Mojo::Base -base;

use Mojo::UserAgent;

has 'ua' => sub { Mojo::UserAgent->new };

has 'start_url';
has 'start_tx';
has 'form_eles';
has 'form';

sub form_url {
	my( $self ) = @_;

	return Mojo::URL->new( $self->form->{action} )->to_abs( Mojo::URL->new( $self->start_url ) ) 
}

sub new { 
	my( $class, $url ) = @_;

	my $self = bless {}, $class;
	$self->start_url( $url );


	my $tx = $self->ua->get( $url );
	$self->start_tx( $tx );

	unless( $tx->success ) { 
		die "Error [$url]: ", (join " ", $tx->error), "\n";
	}

	$self->form( $tx->res->dom->at("form[name=aspnetForm]") );

	$self->form_eles( {  @{ $self->form->find('input')->map(sub{ $_->{name}, $_ }) }  } );

	return $self;
}

sub build_submit_data {
	my( $self, $extra_fields ) = @_;

	my %submit_data;

	for my $ele ( values %{ $self->form_eles } ) { 
		$submit_data{ $ele->{name} } = $ele->{value} unless lc $ele->{type} eq 'submit';
	}

	if( $extra_fields ) { 
		for( keys %$extra_fields ) { $submit_data{ $_ } = $extra_fields->{$_} }
	}

	return \%submit_data;
}

sub submit_form {
	my( $self, $submit_data ) = @_;

	my $tx = $self->ua->build_tx( POST => $self->form_url => form => $submit_data );

	my $form_tx = $self->ua->start( $tx );

	#print $form_tx->req->to_string, "\n";

	return $form_tx;
}

sub click {
	my( $self, $name, $extra_fields ) = @_;

	my $submit_data = $self->build_submit_data( $extra_fields );
	
	if( $self->form_eles->{$name} ) {
		$submit_data->{ $name } = $self->form_eles->{$name}->{value};
	}
	else {
		die "Failed to find input element [$name]\n";
	}

	return $self->submit_form( $submit_data );

}

sub submit_button_names {
	my( $self ) = @_;

	return map $_->{name}, grep lc $_->{type} eq 'submit', values %{ $self->form_eles };
}

1;
