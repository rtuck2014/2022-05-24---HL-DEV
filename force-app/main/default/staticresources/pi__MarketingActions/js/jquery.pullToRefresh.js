(function($){
  $.fn.pull_to_refresh = function(options) {

    var defaults = {
      refresh: function(callback){},
      pull_to_refresh_text: '',
      letgo_text: '',
      refreshing_text: '',
      status_indicator_id: 'pull_to_refresh',
      refresh_class: 'fa fa-refresh fa-2x fa-fw fa-spin',
      visible_class: 'fa fa-refresh fa-2x fa-fw',
    };
    var options = $.extend(defaults, options);

    var content,
        status_indicator,
        refreshing,
        contentStartY = 0,
        startY = 0,
        track = false,
        refresh = false;

    var removeTransition = function() {
      content.css('-webkit-transition-duration',0);
      content.css('top','0');
      status_indicator.css('top','-' + status_indicator.height() + 'px');
      status_indicator.removeClass(options.refresh_class);
      status_indicator.removeClass(options.visible_class);
    };

    // get the different objects
    content = $(this);

    // create the container for the pull indicator
    content.prepend('<div id="' + options.status_indicator_id + '"></div>');
    status_indicator = $('#' + options.status_indicator_id);

    // make sure the content is absolute positioned
    content.css('position','absolute');
    content.css('top',0);

    // move the pull_to_refresh to the top
    status_indicator.css('position','absolute');
    status_indicator.addClass(options.visible_class);
    status_indicator.css('top','-' + status_indicator.height() + 'px');

    var isAtTop = function() {
      return content.offset().top >= $(window).scrollTop();
    }

    // add the listener for the touchdown event, and set the initial values
    document.body.addEventListener('touchstart', function(e) {
      try {
        contentStartY = parseInt(content.css('top'));
      }
      catch(e) {
        contentStartY = 0;
      }
      startY = e.touches[0].screenY;
    });

    // this is where the magic happens, if we stop moving, we check
    // whether we haved moved enough, if so, we set a nice transition, and
    // start the callback
    var refreshTimeout;
    var hasPulledDownLongEnough = false;
    var refreshDelay = 250;
    document.body.addEventListener('touchend', function(e) {
      var move_to = contentStartY - (startY - e.changedTouches[0].screenY);
      // don't do anything unless we're actually near the top of the page
      if(isAtTop() && move_to > 0) {
        track = true; // start tracking if near the top
        // don't move the page's top further than the status indicator's height
        if (move_to > status_indicator.height()) {
          move_to = status_indicator.height();
        }

        if (content.css('top').replace('px', '')) {
          content.css('top',move_to + 'px');
        }
      }

      if(refresh) {
        content.css('top',status_indicator.height() + 'px');
        status_indicator.text(options.refreshing_text);
        status_indicator.addClass(options.refresh_class);

        if (hasPulledDownLongEnough) {
          options.refresh(function() { // pass down done callback
              removeTransition();
          });
        } else {
          removeTransition();
        }
      } else if(track) {
        content.css('top','0');
        setTimeout(function() {
          removeTransition();
        }, refreshDelay);
      } else {
        removeTransition();
      }

      if (refreshTimeout) {
        clearTimeout(refreshTimeout);
      }

      hasPulledDownLongEnough = false;
      refreshTimeout = null;

      refresh = false;
      track = false;
    });

    // on moving of the touch event, we move the diff down
    // unfortunately, for this to work, we need to prevent the default
    // behaviour, which means a broken bounce, any tips would be appreciated!
    document.body.addEventListener('touchmove', function(e) {
      var move_to = contentStartY - (startY - e.changedTouches[0].screenY);
      // don't do anything unless we're actually near the top of the page
      if(isAtTop() && move_to > 0) {
        track = true; // start tracking if near the top

        // don't move the page's top further than the height of the status indicator
        if (move_to > status_indicator.height()) {
          move_to = status_indicator.height();
        }

        if (content.css('top').replace('px', '')) {
          content.css('top',move_to + 'px');
        }
      }

      // have we pull the whole indicator down?
      if(content.css('top').replace('px', '') + 2 >= status_indicator.height()) {
        status_indicator.addClass(options.visible_class);
        status_indicator.text(options.letgo_text);

        // make it so you have to pull down for refreshDelay (250ms) in order to refresh the page
        // This makes it so the page doesn't auto-refresh simply if you're scrolling to the top
        // really quickly
        refreshTimeout = setTimeout(function() {
          refreshTimeout = null;
          hasPulledDownLongEnough = true;
        }, refreshDelay);

        refresh = true;
      } else {
        content.css('-webkit-transition','');
        refresh = false;
      }
    });
  }
})(jQuery);
