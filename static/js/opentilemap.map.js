(function($) {
    $.fn.jqMap = function (options) {
        //定型
        var $self   = $(this);
        var me      = this;
        var $mapdiv = $self.find('.goog-splitpane-first-container');
        var $ctldiv = $self.find('.goog-splitpane-second-container');

        //引数 & デフォルト値
        var defaults = {
            'handleSize'  : 5,
            'deltaWidth'  : 2, //Splitpaneで、Window2の幅を算出するための差の値
            'deltaHeight' : 100,
            'defCenter'   : new L.LatLng(36.0, 135.0),
            'defZoom'     : 5,
            'maxCtlWidth' : 300,
            'minMapWidth' : 400
        };
        options = $.extend(defaults, options);

        //メンバ関数
        this.resize = function(){
            $self.css('height', ($(window).height() - options.deltaHeight));
            $self.css('width', $('#main').width());
            me.setSecondPaneWidth();
        };

        this.setSecondPaneWidth = function(sWidth) {
            if (sWidth === undefined)              { sWidth = $ctldiv.width(); }
            if (sWidth > options.maxCtlWidth) {
                sWidth = options.maxCtlWidth;
            }
            var baseSize = $self.width() - options.deltaWidth - options.handleSize;
            var fWidth   = baseSize - sWidth;
            if (fWidth < options.minMapWidth) {
                fWidth   = options.minMapWidth > baseSize ? baseSize : options.minMapWidth;
            }
            splitpane.setFirstComponentSize(fWidth);
        };

        this.redrawEachLayer = function() {
            $ctldiv.find('td').each(function(){
                var $cell   = $(this);
                var edata   = $cell.attr('data');
                var emapid  = edata.replace('layer_','');
                var layer   = layerList[emapid]['nowLayer'];
                var bData   = layerList[emapid]['baseData'];
                var mapZoom = map.getZoom();
                var lessMin = bData.min_zoom > mapZoom;
                var deltMin = bData.zoom_index - mapZoom;
                if ($cell.hasClass('layerSelected')) {
                    var wantedType = 'tileLayer';
                    if ( deltMin > 3) {
                        wantedType = 'marker';
                    } else if ( deltMin > 1 ) {
                        if ( lessMin ) {
                            wantedType = 'rectangle';
                        } else {
                            wantedType = 'rectTile';
                        }
                    } else if ( lessMin ) {
                        wantedType = 'rectangle';
                    }
                    if (layer.layerType != wantedType) {
                        me.removeLayer(layer);
                        if (wantedType == 'tileLayer') {
                            layer = layerList[emapid]['nowLayer'] = layerList[emapid]['tileLayer'];
                        } else if (wantedType == 'marker') {
                            //日付変更線越え未考慮、緯度中心は緯度で求めている
                            layer = layerList[emapid]['nowLayer'] = L.marker([
                                (bData.max_lat + bData.min_lat) / 2,
                                (bData.max_lng + bData.min_lng) / 2
                            ]);
                            layer.layerType = 'marker';
                            layer.desc      = '<h5 onclick="javascript:mappage.fitToBound(' + bData.map_id + ');return false;">' + bData.map_name + '</h5>';
                        //} else if (wantedType == 'rectangle') {

                        } else {
                            var bounds = [[bData.min_lat, bData.min_lng], [bData.max_lat, bData.max_lng]];
                            var center = new L.LatLng((bData.max_lat + bData.min_lat) / 2,(bData.max_lng + bData.min_lng) / 2);
                            layer = layerList[emapid]['nowLayer'] = L.rectangle(bounds, {color: "#ff7800", weight: 1});
                            layer.zIndex = bData.zoom_index;
                            layer.layerType = wantedType;
                            layer.desc      = '<h5 onclick="javascript:mappage.fitToBound(' + bData.map_id + ');return false;">' + bData.map_name + '</h5>';
                            //layer.on('click', function(e) {
                            //    popup.setContent(layer.desc);
                            //    popup.setLatLng(center);
                            //    map.openPopup(popup);
                            //});
                        }
                    }

                    me.addLayer(layer);
                    map.fire('overlayadd', {layer: layer});
                } else {
                    me.removeLayer(layer);
                    map.fire('overlayremove', {layer: layer});
                }
            });
        };

        this.addLayer = function(layer) {
            if (layer.layerType == 'rectangle' || layer.layerType == 'rectTile') {
                fgp.addLayer(layer);
            } else {
                map.addLayer(layer);
                if (layer.layerType == 'marker') {
                    oms.addMarker(layer);
                }
            }
        };

        this.removeLayer = function(layer) {
            if (layer.layerType == 'rectangle' || layer.layerType == 'rectTile') {
                fgp.removeLayer(layer);
            } else {
                map.removeLayer(layer);
                if (layer.layerType == 'marker') {
                    oms.removeMarker(layer);
                }
            }
        };

        this.fitToBound = function(mapid) {
            map.closePopup();

            var bData = layerList[mapid];
            if (!bData) return;
            bData = bData['baseData'];
            var bounds = new L.LatLngBounds([bData.min_lat, bData.min_lng], [bData.max_lat, bData.max_lng]);
            var expectZoom = map.getBoundsZoom( bounds );
            if (expectZoom < bData.min_zoom) {
                map.setView(bounds.getCenter(),bData.min_zoom);
            } else {
                map.fitBounds(bounds);
            }
        };

        //地図用変数
        var map, mapquest, firstLoad;
        var layerList = {};

        // Google Closure Splitpane用処理
        var lhs = new goog.ui.Component();
        var rhs = new goog.ui.Component();

        // Set up splitpane with already existing DOM.
        var splitpane = new goog.ui.SplitPane(lhs, rhs,
            goog.ui.SplitPane.Orientation.HORIZONTAL);

        splitpane.setHandleSize(options.handleSize);
        splitpane.decorate($self.get(0));
        this.setSecondPaneWidth(options.maxCtlWidth);

        //初期化処理
        firstLoad = true;

        mapquest = new L.TileLayer("http://{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png", {
            maxZoom:     18,
            subdomains:  ["otile1", "otile2", "otile3", "otile4"],
            attribution: 'Basemap tiles courtesy of <a href="http://www.mapquest.com/" target="_blank">MapQuest</a> <img src="http://developer.mapquest.com/content/osm/mq_logo.png">. Map data (c) <a href="http://www.openstreetmap.org/" target="_blank">OpenStreetMap</a> contributors, CC-BY-SA.',
            zIndex:      -1000
        });

        map = new L.Map('map', {
            center: options.defCenter,
            zoom:   options.defZoom,
            layers: [mapquest]
        });
        var oms = new OverlappingMarkerSpiderfier(map,{'keepSpiderfied':true});
        var popup  = new L.Popup({'offset':new L.Point(0,-20)});
        var lPopup = new L.Popup({'offset':new L.Point(0,0)});
        oms.addListener('click', function(marker) {
            popup.setContent(marker.desc);
            popup.setLatLng(marker.getLatLng());
            map.openPopup(popup);
        });

        oms.addListener('spiderfy', function(markers) {
            map.closePopup();
        });

        var fgp = L.featureGroup()
            .on('click',function(e) {
                var desc = '';
                fgp.eachLayer(function (layer) {
                    if (layer.getBounds().contains(e.latlng)) {
                        desc += layer.desc;
                    }
                });
                lPopup.setContent(desc);
                lPopup.setLatLng(e.latlng);
                map.openPopup(lPopup);
            }).addTo(map);

        fgp.on('layeradd',function(){
            map.closePopup();
        });

        fgp.on('layerremove',function(){
            map.closePopup();
        });

        $(document).ready(function() {
            $.ajaxSetup({cache:false});
            me.resize();
            map.invalidateSize();
        });

        $(window).resize(function () {
            me.resize();
        }).resize();

        $mapdiv.exResize(function () {
            if ($ctldiv.width() > options.maxCtlWidth) {
                me.setSecondPaneWidth();
            }
            map.invalidateSize();
        }).resize();

        var OTileMap = L.TileLayer.extend({
            initialize: function (url,options) {
                L.TileLayer.prototype.initialize.call(this, url, options);
                this._tileBoundsForZoom = {};
                this._isMinLngIsEast    = this.minLng > this.maxLng ? true : false;
            },

            getTileUrl: function (tilePoint) {
                var zoom = this._map.getZoom();
                var tileBound = this._tileBoundsForZoom[zoom];
                if (!tileBound) {
                    // 2013.2.18現在、日付変更線越え未対応
                    var sw = L.Projection.SphericalMercator.project({lat:this.options.minLat,lng:this.options.minLng});
                    var ne = L.Projection.SphericalMercator.project({lat:this.options.maxLat,lng:this.options.maxLng});
                    var multiply = Math.pow(2,zoom);
                    var maxTy = Math.floor((this.options.tms ? (Math.PI - sw.y) : (Math.PI - sw.y)) * multiply / (2 * Math.PI));
                    var minTx = Math.floor((sw.x + Math.PI) * multiply / (2 * Math.PI));
                    var minTy = Math.floor((this.options.tms ? (Math.PI - ne.y) : (Math.PI - ne.y)) * multiply / (2 * Math.PI));
                    var maxTx = Math.floor((ne.x + Math.PI) * multiply / (2 * Math.PI));
                    tileBound = this._tileBoundsForZoom[zoom] = [minTy,minTx,maxTy,maxTx];
                }
                if (tilePoint.x < tileBound[1] || tilePoint.x > tileBound[3] || tilePoint.y < tileBound[0] || tilePoint.y > tileBound[2]) {
                    return this.options.errorTileUrl;
                }
                return L.TileLayer.prototype.getTileUrl.call(this, tilePoint);
            }
        });

        var checkMapExist = function(e) {
            var bounds  = map.getBounds();
            var min_lng = bounds.getSouthWest().lng;
            var max_lng = bounds.getNorthEast().lng;
            var min_lat = bounds.getSouthWest().lat;
            var max_lat = bounds.getNorthEast().lat;
            var zoom    = map.getZoom();

            $.get (
                '/ajax/listmaps?callback=?',
                {
                    'min_lng' : min_lng,
                    'max_lng' : max_lng,
                    'min_lat' : min_lat,
                    'max_lat' : max_lat,
                    'zoom'    : zoom
                },
                function (data) {
                    var oldList = [];
                    for (var key in layerList) {
                        oldList[key] = layerList[key];
                    }
                    var newList = data.maps;

                    var $beforeCell = null;
                    for (var i=newList.length-1;i>=0;i--) {
                        var newtile = newList[i];
                        var new_id  = newtile.map_id;

                        var $thisCell;
                        if (oldList[new_id]) {
                            delete oldList[new_id];
                            $thisCell = $(layerList[new_id]['ctlCell']);
                        } else {
                            var tileurl  = newtile.map_url;
                            var tilename = newtile.map_name;
                            var is_tms   = newtile.is_tms;
                            var tileattr = newtile.attribution;
                            var subdoms  = [];

                            var match = tileurl.match(/\{((?:\w+,)+\w+)\}/);
                            if (match) {
                                subdoms = match[1].split(',');
                                tileurl = tileurl.replace(/\{((?:\w+,)+\w+)\}/,"{s}");
                            }

                            var undefined;
                            for (var tkey in newtile) {
                                switch (tkey){
                                  case 'min_zoom':
                                  case 'max_zoom':
                                    if (newtile[tkey] !== undefined) { newtile[tkey] = parseInt(newtile[tkey]); }
                                    break;
                                  case 'min_lat':
                                  case 'max_lat':
                                  case 'min_lng':
                                  case 'max_lng':
                                  case 'min_year':
                                  case 'max_year':
                                  case 'zoom_index':
                                    if (newtile[tkey] !== undefined) { newtile[tkey] = parseFloat(newtile[tkey]); }
                                    break;
                                }
                            }

                            var newLayer = new OTileMap(tileurl, {
                                attribution: tileattr,
                                tms:         is_tms,
                                subdomains:  subdoms,
                                minZoom:     newtile.min_zoom,
                                maxZoom:     newtile.max_zoom,
                                minLat:      newtile.min_lat,
                                minLng:      newtile.min_lng,
                                maxLat:      newtile.max_lat,
                                maxLng:      newtile.max_lng,
                                zIndex:      Math.floor(newtile.zoom_index * 100)
                            });
                            newLayer.layerType = 'tileLayer';
                            $thisCell = $('<tr><td class="action_link layerSelected" data="layer_' + new_id + '" style="cursor:pointer;"><h5>' + tilename + '</h5></td></tr>');
                            layerList[new_id] = {
                                "baseData"  : newtile,
                                "tileLayer" : newLayer,
                                "ctlCell"   : $thisCell.get(0),
                                "nowLayer"  : newLayer
                            };
                        }
                        if ($beforeCell) {
                            $beforeCell.before($thisCell);
                        } else {
                            $ctldiv.find('table').prepend($thisCell);
                        }
                        $beforeCell = $thisCell;
                    }
                    me.redrawEachLayer();

                    for (var old_key in oldList) {
                        var oldLayer = layerList[old_key]['nowLayer'];
                        var oldCell  = layerList[old_key]['ctlCell'];
                        me.removeLayer(oldLayer);
                        $(oldCell).remove();
                        delete layerList[old_key];
                    }

                }, 'json'
            );
        };

        map.on('moveend',checkMapExist);

        $self.on('click', '.action_link', function(e) {
            var data  = $(this).attr('data');
            if ( data.match(/^([a-zA-Z]+)_([0-9]+)$/) ) {
                var command = RegExp.$1;
                var mapid   = RegExp.$2;

                switch (command){
                  case 'layer':
                    if ($(this).hasClass('layerSelected')) {
                        $(this).removeClass('layerSelected');
                    } else {
                        $(this).addClass('layerSelected');
                    }
                    me.redrawEachLayer();
                    break;
                  case 'bounds':
                    console.log(mapid);
                    break;
                  default:
                    break;
                }
            }

            return false;
        });

        return this;
    };
})(jQuery);