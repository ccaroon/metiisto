/******************************************************************************/
var Metiisto = {
    toggle_set: function(elem_name, on_off) {
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
};
/******************************************************************************/
Metiisto.countDowns = {
    // Compute interval between NOW and target_date formated as DD:HH::MM::SS
    compute_time_left: function (target_date) {
        var now_ms  = new Date().valueOf();
        var date_ms = target_date.valueOf();
        var secs = Math.round((date_ms - now_ms) / 1000);

        secs = (secs >= 0 ) ? secs : Math.abs(secs);

        return (Metiisto.countDowns.format_DHMS(secs))
    },

    // Formats num_secs as DD:HH::MM::SS string
    format_DHMS: function (num_secs) {
        var days = Math.floor(num_secs / 86400);
        num_secs = num_secs % 86400;
        
        var hours = Math.floor(num_secs / 3600);
        num_secs = num_secs % 3600;
        
        var mins = Math.floor(num_secs / 60);
        var secs = num_secs % 60;
        
        return (
            ((days > 9) ? days : '0' + days)
            + ':' +
            ((hours > 9) ? hours : '0' + hours)
            + ':' +
            ((mins > 9)  ? mins  : '0' + mins)
            + ':' +
            ((secs > 9)  ? secs  : '0' + secs)
        );
    }    
};
