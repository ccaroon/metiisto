package Metiisto::Weather;
################################################################################
use strict;

use LWP::Simple;
use JSON::XS;

use constant CACHE_TTL => 5 * 60;
use constant WI_ICON_MAP => {
    "Cloudy"           => 'wi-cloudy',
    "Mostly Cloudy"    => 'wi-day-cloudy',
    "Partly Cloudy"    => 'wi-day-sunny-overcast',
    "Scattered Clouds" => 'wi-day-sunny-overcast',
    "Fair"             => 'wi-day-sunny',
    "Rain"             => 'wi-rain',
    "Overcast"         => 'wi-cloudy',
    "Thunderstorm"     => 'wi-thunderstorm'
};
################################################################################
sub current
{
    my $class = shift;
    my %args  = @_;

    my $cache_key = "weather_data_$args{location}";

    my $data = Metiisto::Util::Cache->get(key => $cache_key);
    unless ($data)
    {
        $data = $class->_fetch_data(location => $args{location});
        if ($data)
        {
            Metiisto::Util::Cache->set(
                key   => $cache_key,
                value => $data,
                ttl   => CACHE_TTL
            );
        }
    }

    my %weather;
    if ($data)
    {
        %weather = (
            wi_icon => $class->text2wi_icon($data->{weather}),
            text    => $data->{weather},
            temp    => $data->{temp_f},
            url     => $data->{ob_url}
        );
    }

    return (wantarray ? %weather : \%weather);
}
################################################################################
# Convert text to 'weather-icon' icon name
################################################################################
sub text2wi_icon
{
    my $class = shift;
    my $text  = shift;
    my $icon  = WI_ICON_MAP->{$text} || 'wi-alien';

    return ($icon);
}
################################################################################
sub _fetch_data
{
    my $class = shift;
    my %args = @_;

    my $data = undef;
    # TODO: make API key a preference
    my $json = get("http://api.wunderground.com/api/8f4b19c7f8963947/conditions/q/$args{location}.json");
    if ($json)
    {
        $data = decode_json $json;
        $data = $data->{current_observation};
    }

    return($data);
}
################################################################################
1;
