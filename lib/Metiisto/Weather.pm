package Metiisto::Weather;
################################################################################
use strict;

use LWP::Simple;
use XML::Simple;

use constant YAHOO_WEATHER_ID => '12769146';
################################################################################
sub current
{
    my $class = shift;

    my $data = Metiisto::Util::Cache->get(key => 'weather_data');
    unless ($data)
    {
        $data = $class->_fetch_data();
        Metiisto::Util::Cache->set(
            key   => 'weather_data',
            value => $data,
            ttl   => 30 * 60
        );
    }

    my %weather = (
        icon => "http://l.yimg.com/a/i/us/we/52/$data->{'yweather:condition'}->{code}.gif",
        text => $data->{'yweather:condition'}->{text},
        temp => $data->{'yweather:condition'}->{temp}
    );

    return (wantarray ? %weather : \%weather);
}
################################################################################
sub _fetch_data
{
    my $class = shift;
print STDERR "=====> Weather.pm #37 --> GETTING WEATHER DATA \n";
    my $xml = get('http://weather.yahooapis.com/forecastrss?w='.YAHOO_WEATHER_ID);
    my $data = XMLin($xml);

    return($data->{channel}->{item});
}
################################################################################
1;
__END__
<?xml version="1.0" encoding="UTF-8" standalone="yes" ?>
                <rss version="2.0" xmlns:yweather="http://xml.weather.yahoo.com/ns/rss/1.0" xmlns:geo="http://www.w3.org/2003/01/geo/wgs84_pos#">
                        <channel>

<title>Yahoo! Weather - Raleigh, NC</title>
<link>http://us.rd.yahoo.com/dailynews/rss/weather/Raleigh__NC/*http://weather.yahoo.com/forecast/USNC0107_f.html</link>
<description>Yahoo! Weather for Raleigh, NC</description>
<language>en-us</language>
<lastBuildDate>Mon, 07 Jan 2013 10:49 am EST</lastBuildDate>
<ttl>60</ttl>
<yweather:location city="Raleigh" region="NC"   country="United States"/>
<yweather:units temperature="F" distance="mi" pressure="in" speed="mph"/>
<yweather:wind chill="40"   direction="50"   speed="14" />
<yweather:atmosphere humidity="54"  visibility="10"  pressure="30.42"  rising="1" />
<yweather:astronomy sunrise="7:24 am"   sunset="5:15 pm"/>
<image>
<title>Yahoo! Weather</title>
<width>142</width>
<height>18</height>
<link>http://weather.yahoo.com</link>
<url>http://l.yimg.com/a/i/brand/purplelogo//uh/us/news-wea.gif</url>
</image>
<item>
<title>Conditions for Raleigh, NC at 10:49 am EST</title>
<geo:lat>35.74</geo:lat>
<geo:long>-78.72</geo:long>
<link>http://us.rd.yahoo.com/dailynews/rss/weather/Raleigh__NC/*http://weather.yahoo.com/forecast/USNC0107_f.html</link>
<pubDate>Mon, 07 Jan 2013 10:49 am EST</pubDate>
<yweather:condition  text="Partly Cloudy"  code="30"  temp="46"  date="Mon, 07 Jan 2013 10:49 am EST" />
<description><![CDATA[
<img src="http://l.yimg.com/a/i/us/we/52/30.gif"/><br />
<b>Current Conditions:</b><br />
Partly Cloudy, 46 F<BR />
<BR /><b>Forecast:</b><BR />
Mon - Sunny. High: 50 Low: 28<br />
Tue - Partly Cloudy. High: 54 Low: 43<br />
<br />
<a href="http://us.rd.yahoo.com/dailynews/rss/weather/Raleigh__NC/*http://weather.yahoo.com/forecast/USNC0107_f.html">Full Forecast at Yahoo! Weather</a><BR/><BR/>
(provided by <a href="http://www.weather.com" >The Weather Channel</a>)<br/>
]]></description>
<yweather:forecast day="Mon" date="7 Jan 2013" low="28" high="50" text="Sunny" code="32" />
<yweather:forecast day="Tue" date="8 Jan 2013" low="43" high="54" text="Partly Cloudy" code="30" />
<guid isPermaLink="false">USNC0107_2013_01_08_7_00_EST</guid>
</item>
</channel>
</rss>

<!-- api20.weather.bf1.yahoo.com Mon Jan  7 17:30:32 PST 2013 -->
