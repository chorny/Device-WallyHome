package Device::WallyHome::Role::REST;
use Moose::Role;
use MooseX::AttributeShortcuts;

use Data::Dumper;
use HTTP::Headers;
use HTTP::Request;
use JSON::MaybeXS qw(decode_json);
use LWP::UserAgent;

our $VERSION = 0.01;


#== ATTRIBUTES =================================================================

has 'apiHostname' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'api.snsr.net',
);

has 'apiUseHttps' => (
    is      => 'rw',
    isa     => 'Int',
    default => 1,
);

has 'apiVersion' => (
    is      => 'rw',
    isa     => 'Str',
    default => 'v2',
);

has 'lastApiError' => (
    is     => 'ro',
    isa    => 'Maybe[Str]',
    writer => '_lastApiError',
);

has 'token' => (
    is       => 'rw',
    isa      => 'Str',
    required => 1,
);

has 'userAgentName' => (
    is => 'lazy',
);

has 'timeout' => (
    is      => 'rw',
    isa     => 'Int',
    default => '180',
);

has '_userAgent' => (
    is => 'lazy',
);


#== ATTRIBUTE BUILDERS =========================================================

sub _build__userAgent {
    my ($self) = @_;

    return LWP::UserAgent->new(
        agent   => $self->userAgentName(),
        timeout => $self->timeout(),
    );
}

sub _build_userAgentName {
    return "Device::WallyHome v$VERSION";
}


#== PUBLIC METHODS =============================================================

sub baseUrl {
    my ($self) = @_;

    my $s = $self->apiUseHttps() ? 's' : '';

    return "http$s://" . $self->apiHostname() . '/' . $self->apiVersion() . '/';
}

sub headers {
    my ($self) = @_;

    my $headers = HTTP::Headers->new();

    $headers->header('Authorization' => 'Bearer ' . $self->token());

    return $headers;
}

sub request {
    my ($self, $params) = @_;

    $params //= {};

    die 'invalid params: ' . Dumper($params) unless ref($params) && ref($params) eq 'HASH';

    my $uri = $params->{uri} // die 'uri required';

    my $content = $params->{content} // undef;
    my $headers = $params->{headers} // $self->headers();
    my $method  = $params->{method}  // 'GET';

    my $request = HTTP::Request->new($method, $self->wallyUrl($uri), $headers, $content);

    my $response = $self->_userAgent()->request($request);

    my $decodedResponse = {};

    eval {
        $decodedResponse = decode_json($response->content());
    };

    if ($@) {
        $self->_lastApiError($@);

        return undef;
    }

    return $decodedResponse;
}

sub wallyUrl {
    my ($self, $path) = @_;

    return $self->baseUrl() . $path;
}

1;
