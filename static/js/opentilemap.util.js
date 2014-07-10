function htmlEncode(value){
    return $('<div/>').text(value).html();
}
function htmlDecode(value){
    return $('<div/>').html(value).text();
}
(function($) {

    $.validator.methods['map_url'] = function(value, element) {
        return this.optional(element) || /^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|(\{(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+,)+([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+\}\.)?((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@|\{(x|\y|z)\})+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@|\{(x|\-?y|z)\})*)*)?)?(\?((([a-z]|\{(x|\y|z)\}|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(value);

        //^(https?|ftp):\/\/(((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:)*@)?(((\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5])\.(\d|[1-9]\d|1\d\d|2[0-4]\d|25[0-5]))|(\{(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+,)+([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+\}\.)?((([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.)+(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])*([a-z]|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])))\.?)(:\d*)?)(\/((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@|\{([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+\})+(\/(([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@|\{([a-z]|\d|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])+\})*)*)?)?(\?((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|[\uE000-\uF8FF]|\/|\?)*)?(\#((([a-z]|\d|-|\.|_|~|[\u00A0-\uD7FF\uF900-\uFDCF\uFDF0-\uFFEF])|(%[\da-f]{2})|[!\$&'\(\)\*\+,;=]|:|@)|\/|\?)*)?$/i.test(value);
    };
    $.validator.messages['map_url'] = "Please enter a valid Map tile's template URL.";
    $.validator.methods['more_than'] = function(value, element, param) {
        var target = $(param);
        if (this.settings.onfocusout) {
            target.unbind(".validate-moreThan").bind("blur.validate-moreThan", function() {
                $(element).valid();
            });
        }
        return parseFloat(value) > parseFloat(target.val());
    };
    $.validator.methods['end_year'] = function(value, element, param) {
        var $check  = $(param[1]);
        var $target = $(param[0]);
        if (this.settings.onfocusout) {
            $target.unbind(".validate-endYear").bind("blur.validate-endYear", function() {
                $(element).valid();
            });
        }
        return !$check.is(":checked") || parseInt(value) > parseInt($target.val());
    };
    $.validator.methods['decimal'] = function(value, element) {
        return this.optional(element) || /^\-?[0-9]+$/.test(value);
    };
    $.validator.messages['decimal'] = "Please enter a decimal value.";

    $.fn.jqModalBase = function (options) {
        $.jqModalBase(this, options);
        return this;
    };
    $.jqModalBase = function (container, options) {
        var binder = $(container)[0];
        return binder.jqModalBase || (binder.jqModalBase = new $._jqModalBase(container, options));
    };
    $._jqModalBase = function (container, options) {
        var $self = $(container);
        var me    = this;

        var activeContainer = null;

        this.setActiveContainer = function(container) {
            //消し忘れを防ぐ
            if (activeContainer && activeContainer.hide) {
                activeContainer.hide();
            }
            $self.find('.modal_forms').hide();

            activeContainer = container;
            $self.find('h3').text(container.modalTitle);
            if (container.noModalFooter) {
                $('.modal-footer').hide();
            } else {
                $('.modal-footer').show();
            }
            if (container.show) {
                container.show();
            } else {
                $(container).show();
            }
            me.show();
        };

        this.show = function() {
            $self.modal('show');
        };

        this.hide = function() {
            if (activeContainer) {
                if (activeContainer.hide) {
                    activeContainer.hide();
                }
                activeContainer = null;
            }
            $self.find('.modal_forms').hide();
            $self.modal('hide');
        };

        $self.on('click', '.action_link', function(e) {
            var data = $(this).attr('data');
            var ret  = false;
            switch (data) {
                case 'dismiss':
                    me.hide();
                    break;
                case 'submit':
                    if (activeContainer && activeContainer.submit) {
                        activeContainer.submit();
                    }
                    break;
                default:
                    if (activeContainer && activeContainer.do_action_link) {
                        ret = activeContainer.do_action_link(data, this);
                    }
            }
            return ret;
        });
    };

    $.fn.jqAccount = function (options) {
        var $self  = $(this);
        var me     = this;
        var $modal = $.jqModalBase('#modalBase');

        this.modalTitle = 'Edit account';

        $self.find('form').validate();

        this.hide = function() {
            $self.find('input[name=user_name]').val(options.user_name);
            $self.find('form').valid();
        };

        this.submit = function() {
            if (!$self.find('form').valid()) {
                return;
            }
            $.post (
                '/ajax/account?callback=?',
                {
                    'csrf_token' : $self.find('input[name=csrf_token]').val(),
                    'user_name'  : $self.find('input[name=user_name]').val()
                },
                function (data) {
                    if (data.result) {
                        options.user_name = data.user_name;
                        $('a.user_name span').html('Hello,' + htmlEncode(data.user_name));
                    } else {
                        alert('Fail to change account name');
                    }
                    $modal.hide();
                }, 'json'
            );
        };

        $(document).on('click','[data-toggle=editaccount]',function(){
            $modal.setActiveContainer(me);
            return true;
        });
    };

    $.fn.jqListMaps = function (options) {
        var $self    = $(this);
        var me       = this;
        var $modal   = $.jqModalBase('#modalBase');
        var lastpage = 1;

        this.modalTitle = 'Manage your maps';
        this.noModalFooter = true;

        this.do_action_link = function(data, target) {
            if (data.search('changepage_') === 0) {
                var page = data.replace('changepage_','');
                me.listMaps(page);
            } else if (data.search('editmap_') === 0) {
                var map_id = data.replace('editmap_','');
                $modal.hide();
                $.jqEditMapMeta('#editMapMeta').editMap(map_id);
            } else if (data.search('collapsemap_') === 0) {
                $('.dropdownmap').hide();
                $(target).find('.dropdownmap').show();
            } else if (data.search('deletemap_') === 0) {
                if (window.confirm("Delete this map? This processing cannot be canceled.")) {
                    var map_id = data.replace('deletemap_','');
                    $.post (
                        '/ajax/deletemap?callback=?',
                        {
                            'csrf_token' : options.csrf_token,
                            'map_id' : map_id
                        },
                        function (data) {
                            me.listMaps(lastpage);
                        }, 'json'
                    );
                }
            }
            return false;
        };

        this.listMaps = function(page, showAfter) {
            lastpage = page;
            $.get (
                '/ajax/listmaps?callback=?',
                {
                    'page' : page
                },
                function (data) {
                    $self.html($('#js_listmaps_template').tmpl(data));
                    if (showAfter) {
                        $modal.setActiveContainer(me);
                    }
                }, 'json'
            );
        };

        $(document).on('click','[data-toggle=listmaps]',function(){
            me.listMaps(1,true);
            return true;
        });
    };

    // EditMap
    $.fn.jqEditMapMeta = function (options) {
        $.jqEditMapMeta(this, options);
        return this;
    };
    $.jqEditMapMeta = function (container, options) {
        var binder = $(container)[0];
        return binder.jqEditMapMeta || (binder.jqEditMapMeta = new $._jqEditMapMeta(container, options));
    };
    $._jqEditMapMeta = function (container, options) {
        var $self  = $(container);
        var me     = this;
        var $modal = $.jqModalBase('#modalBase');

        this.modalTitle = 'Edit Map Metadata';

        this.do_action_link = function(data) {
            if (data == 'parsexml') {
                var uriForm = $self.find('input[name=xml_url]');
                if (!uriForm.valid() || uriForm.is(':blank')) {
                    alert('Please enter a valid URL.');
                } else {
                    $.get (
                        '/ajax/parsexml?callback=?',
                        {
                            'csrf_token' : options.csrf_token,
                            'xml_url'     : $self.find('input[name=xml_url]').val()
                        },
                        function (data) {
                            if (data.result) {
                                var meta = data.meta;
                                $self.find('input[name=map_name]'    ).val(meta.map_name);
                                $self.find('input[name=description]' ).val(meta.description);
                                $self.find('input[name=attribution]' ).val(meta.attribution);
                                $self.find('input[name=min_lat]'     ).val(meta.min_lat);
                                $self.find('input[name=max_lat]'     ).val(meta.max_lat);
                                $self.find('input[name=min_lng]'     ).val(meta.min_lng);
                                $self.find('input[name=max_lng]'     ).val(meta.max_lng);
                                $self.find('input[name=min_zoom]'    ).val(meta.min_zoom);
                                $self.find('input[name=max_zoom]'    ).val(meta.max_zoom);
                                $self.find('input[name=map_url]'     ).val(meta.map_url);
                                if (meta.is_tms) {
                                    $self.find('input[name=is_tms]'      ).attr('checked', "checked");
                                } else {
                                    $self.find('input[name=is_tms]'      ).removeAttr('checked');
                                }

                            } else {
                                alert(data.message);
                                me.resetForm();
                            }
                        }, 'json'
                    );
                }
            } else if (data == 'use_endyear') {
                var $max_year = $self.find('input[name=max_year]');
                var $min_year = $self.find('input[name=min_year]');
                if ($self.find('input[name=use_endyear]').is(":checked")) {
                    $max_year.parent('span').show();
                    $max_year.val($min_year.val());
                    $min_year.attr('placeholder','Start year');
                } else {
                    $max_year.parent('span').hide();
                    $max_year.val('');
                    $min_year.attr('placeholder','Year');
                    $max_year.valid();
                }
                return true;
            }
            return false;
        };

        this.show = function() {
            $self.show();
        };

        this.hide = function() {
            me.resetForm();
        };

        this.submit = function() {
            if (!$self.find('form').valid()) {
                return;
            }

            $.post (
                '/ajax/addmap?callback=?',
                {
                    'csrf_token'  : options.csrf_token,
                    'map_id'      : $self.find('input[name=map_id]'      ).val(),
                    'xml_url'     : $self.find('input[name=xml_url]'     ).val(),
                    'map_name'    : $self.find('input[name=map_name]'    ).val(),
                    'description' : $self.find('input[name=description]' ).val(),
                    'attribution' : $self.find('input[name=attribution]' ).val(),
                    'min_lat'     : $self.find('input[name=min_lat]'     ).val(),
                    'max_lat'     : $self.find('input[name=max_lat]'     ).val(),
                    'min_lng'     : $self.find('input[name=min_lng]'     ).val(),
                    'max_lng'     : $self.find('input[name=max_lng]'     ).val(),
                    'min_zoom'    : $self.find('input[name=min_zoom]'    ).val(),
                    'max_zoom'    : $self.find('input[name=max_zoom]'    ).val(),
                    'map_url'     : $self.find('input[name=map_url]'     ).val(),
                    'min_year'    : $self.find('input[name=min_year]'    ).val(),
                    'max_year'    : $self.find('input[name=max_year]'    ).val(),
                    'is_tms'      : $self.find('input[name=is_tms]'      ).is(":checked") ? 1 : 0
                },
                function (data) {
                    if (!data.result) {
                        alert('Fail to add new map');
                    }
                    $modal.hide();
                }, 'json'
            );
        };

        this.resetForm = function () {
            //$self.find('input,textarea').not('input[type="radio"],input[type="checkbox"],:hidden,:button, :submit,:reset').val('');
            //$self.find('input[type="radio"], input[type="checkbox"], select').removeAttr('checked').removeAttr('selected');
            this.buildForm();
        };

        this.buildForm = function (data) {
            var serial;
            if (!data) {
                serial = $self.find('input[name=serial]').val() || '{}';
                data   = JSON.parse(serial);
            } else {
                serial = JSON.stringify(data);
            }
            data.use_endyear = (!data.min_year || !data.max_year || data.min_year == data.max_year) ? 0 : 1;
            $self.find("form").html($('#js_editmap_template').tmpl(data));

            this.validator = $self.find('form').validate({
                rules : {
                    "map_url"  : {
                        "map_url"   : true
                    },
                    "max_lat"  : {
                        "more_than" : 'input[name=min_lat]'
                    },
                    "max_zoom" : {
                        "more_than" : 'input[name=min_zoom]'
                    },
                    "min_year" : {
                        "decimal"   : true
                    },
                    "max_year" : {
                        "decimal"   : true,
                        "end_year"  : ['input[name=min_year]','input[name=use_endyear]']
                    }
                },
                messages : {
                    "max_lat"  : {
                        "more_than" : 'Latitude of North border must be larger than that of South.'
                    },
                    "max_zoom" : {
                        "more_than" : 'Value of Maximum zoom must be larger than that of Minimum zoom.'
                    },
                     "max_year" : {
                        "end_year"  : 'Value of End year must be larger than that of Start year.'
                    }
                },
                groups : {
                    "lat"  : "min_lat max_lat",
                    "lng"  : "min_lng max_lng",
                    "zoom" : "min_zoom max_zoom",
                    "year" : "min_year max_year"
                }
            });

            $self.find('[placeholder]').ahPlaceholder({
                placeholderColor : 'silver',
                placeholderAttr  : 'placeholder',
                likeApple        : false
            });

            //ラベル幅合わせ
            var max = 100;
            $self.find(".form_label").each(function(){
                if ($(this).width() > max) max = $(this).width();
            });
            $self.find(".form_label").width(max).css({"float":"left", "clear":"both", "padding":"3px 0px 0px 0px"});
        };

        this.editMap = function(map_id) {
            $.get (
                '/ajax/getmap?callback=?',
                {
                    'map_id' : map_id
                },
                function (data) {
                    if (!data.result) {
                        alert('Fail to get map data');
                    } else {
                        me.modalTitle = 'Edit map metadata';
                        me.buildForm(data.map);
                        $modal.setActiveContainer(me);
                    }
                }, 'json'
            );
        };

        $(document).on('click','[data-toggle=addmap]',function(){
            me.modalTitle = 'Add new map';
            me.buildForm({});
            $modal.setActiveContainer(me);
            return true;
        }).on('click','[data-toggle=editmap]',function(){
            var map_id = $(this).attr('data');
            me.editMap(map_id);
            return true;
        });
    };

})(jQuery);
