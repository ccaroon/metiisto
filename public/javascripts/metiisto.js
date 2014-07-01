/******************************************************************************/
function toggle_set(elem_name, on_off)
{
    var elem_id = '#'+elem_name,
        value,
        icon;

    if (on_off == true)
    {
        icon = $(elem_id).data('icon_on');
        value = 1;
    }
    else
    {
        icon = $(elem_id).data('icon_off');
        value = 0;
    }
    $( elem_id ).attr('value', value);
    $( elem_id ).html('<i class="fa fa-'+icon+'"></i>');
    // <button> does not submit it's value, so using a hidden field to get
    // this data back to the controller.
    $( elem_id+'_value').attr('value', value);
}
