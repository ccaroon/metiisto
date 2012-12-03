/******************************************************************************/
function toggle_set(elem_name, on_off)
{
    var elem_id = '#'+elem_name;

    var options;
    if (on_off == true)
    {
        var icon = $(elem_id).data('icon_on');
        options = {
            value: 1,
            icons: {
                primary: "ui-icon-"+icon
            }
        };
    }
    else
    {
        var icon = $(elem_id).data('icon_off');
        options = {
            value: 0,
            icons: {
                primary: "ui-icon-"+icon
            }
        };
    }
    $( elem_id ).button( "option", options );
    $( elem_id ).attr('value', options.value);
    // <button> does not submit it's value, so using a hidden field to get
    // this data back to the controller.
    $( elem_id+'_value').attr('value', options.value);
}
