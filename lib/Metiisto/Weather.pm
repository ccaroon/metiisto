package Metiisto::Weather;
################################################################################
use strict;

use LWP::Simple;
use JSON::XS;

use constant CACHE_TTL => 5 * 60;
use constant WI_ICON_MAP => {
    'clear'                        => 'wi-day-sunny',
    'cloudy'                       => 'wi-cloudy',
    'fair'                         => 'wi-day-sunny',
    'fog'                          => 'wi-fog',
    'haze'                         => 'wi-fog',
    'light rain'                   => 'wi-sprinkle',
    'light thunderstorms and rain' => 'wi-storm-showers',
    'mostly cloudy'                => 'wi-day-cloudy',
    'overcast'                     => 'wi-cloudy',
    'partly cloudy'                => 'wi-day-sunny-overcast',
    'rain'                         => 'wi-rain',
    'scattered clouds'             => 'wi-day-sunny-overcast',
    'thunderstorm'                 => 'wi-thunderstorm'
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
        my $icon_text = $data->{weather} || $data->{icon};
        %weather = (
            wi_icon => $class->text2wi_icon(lc($icon_text)),
            text    => $data->{weather},
            temp    => $data->{temp_f},
            url     => $data->{forecast_url}
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
