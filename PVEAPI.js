// avoid errors when running without development tools
if (!Ext.isDefined(Ext.global.console)) {   
    var console = { 
        dir: function() {}, 
        log: function() {} 
    };
}

Ext.onReady(function() {

    Ext.define('pve-param-schema', {
        extend: 'Ext.data.Model',
        fields:  [ 
	    'name', 'type', 'typetext', 'description', 'enum', 
	    'minimum', 'maximum', 'minLength', 'maxLength',
	    'pattern', 'title', 'requires', 'format', 'default',
	    'disallow', 'extends', 'links',
	    {
		name: 'optional',
		type: 'boolean'
	    }
	]
    });

    var store = Ext.create('Ext.data.TreeStore', {
	model: Ext.define('pve-api-doc', {
            extend: 'Ext.data.Model',
            fields:  [ 
		'path', 'info', 'text',
	    ]
	}),
        proxy: {
            type: 'memory',
            data: pveapi
        },
        sorters: [{
            property: 'leaf',
            direction: 'ASC'
        }, {
            property: 'text',
            direction: 'ASC'
        }]
    });
    
    var render_text = function(value, metaData, record) {
	var pdef = record.data;

	metaData.style = 'white-space:pre-wrap;'

	return Ext.htmlEncode(value);
    };

    var render_type = function(value, metaData, record) {
	var pdef = record.data;

	return pdef['enum'] ? 'enum' : (pdef.type || 'string');
    };

    var render_format = function(value, metaData, record) {
	var pdef = record.data;

	metaData.style = 'white-space:normal;'

	if (pdef.typetext)
	    return pdef.typetext;

	if (pdef['enum'])
	    return pdef['enum'].join(' | ');

	if (pdef.format) 
	    return pdef.format;

	if (pdef.pattern) 
	    return pdef.pattern;

	return '';
    };

    var render_docu = function(data) {
	var md = data.info;

	// console.dir(data);

	var items = [];

	var clicmdhash = {
	    GET: 'get',
	    POST: 'create',
	    PUT: 'set',
	    DELETE: 'delete'
	};

	Ext.Array.each(['GET', 'POST', 'PUT', 'DELETE'], function(method) {
	    var info = md[method];
	    if (info) {

		var usage = "";

		usage += "<table><tr><td>HTTP:&nbsp;&nbsp;&nbsp;</td><td>" + method + " /api2/json" + data.path + "</td></tr><tr><td>&nbsp</td></tr>";
		usage += "<tr><td>CLI:</td><td>pvesh " + clicmdhash[method] + " " + data.path + "</td></tr></table>";

		var sections = [
		    {
			title: 'Description',
			html: Ext.htmlEncode(info.description),
			bodyPadding: 10
		    },
		    {
			title: 'Usage',
			html: usage,
			bodyPadding: 10
		    }
		];

		if (info.parameters && info.parameters.properties) {

		    var pstore = Ext.create('Ext.data.Store', {
			model: 'pve-param-schema',
			proxy: {
			    type: 'memory'
			},
			groupField: 'optional',
			sorters: [
			    {
				property: 'name',
				direction: 'ASC'
			    }
			]
		    });

		    Ext.Object.each(info.parameters.properties, function(name, pdef) {
			pdef.name = name;
			pstore.add(pdef);
		    });

		    pstore.sort();

		    var groupingFeature = Ext.create('Ext.grid.feature.Grouping',{
			enableGroupingMenu: false,
			groupHeaderTpl: '<tpl if="name">Optional</tpl><tpl if="!name">Required</tpl>'
		    });

		    sections.push({
			xtype: 'gridpanel',
			title: 'Parameters',
			features: [groupingFeature],
			store: pstore,
			viewConfig: {
			    trackOver: false,
			    stripeRows: true
			},
			columns: [
			    { 
				header: 'Name',
				dataIndex: 'name'
			    },
			    { 
				header: 'Type',
				dataIndex: 'type',
				renderer: render_type,
			    },
			    { 
				header: 'Format',
				dataIndex: 'type',
				renderer: render_format,
				flex: 1
			    },
			    { 
				header: 'Description',
				dataIndex: 'description',
				renderer: render_text,
				flex: 2
			    }
			]
		    });

		}

		if (info.returns) {

		    var rtype = info.returns.type;
		    if (!rtype && info.returns.items)
			rtype = 'array';
		    if (!rtype)
			rtype = 'object';

		    sections.push({
			title: 'Returns: ' + rtype
		    });
		}

		var permhtml = '';
		if (!info.permissions) {
		    permhtml = "Root only.";
		} else {
		    if (info.permissions.description) {
			permhtml += "<div style='white-space:pre-wrap;padding-bottom:10px;'>" +
			    Ext.htmlEncode(info.permissions.description) + "</div>";
		    }

		    if (info.permissions.user) {
			if (!info.permissions.description) {
			    if (info.permissions.user === 'world') {
				permhtml += "Accessible without any authententification.";
			    } else if (info.permissions.user === 'all') {
				permhtml += "Accessible by all authententicated users.";
			    } else {
				permhtml += 'Onyl accessible by user "' + 
				    info.permissions.user + '"';
			    }
			}
		    } else if (info.permissions.check) {
			permhtml += "<pre>Check: " + 
			    Ext.htmlEncode(Ext.JSON.encode(info.permissions.check))  + "</pre>";
		    } else {
			permhtml += "Unknown systax!";
		    }
		}

		sections.push({
		    title: 'Required permissions',
		    bodyPadding: 10,
		    html: permhtml
		});
    
  
		items.push({
		    title: method,
		    autoScroll: true,
		    defaults: {
			border: false
		    },
		    items: sections
		});
	    }
	});

	var ct = Ext.getCmp('docview');
	ct.setTitle("Path: " + data.path);
	ct.removeAll(true);
	ct.add(items);
    };

    var tree = Ext.create('Ext.tree.Panel', {
        title: 'Resource Tree',
        store: store,
	width: 200,
        region: 'west',
        split: true,
        margins: '5 0 5 5',
        rootVisible: false,
	listeners: {
	    selectionchange: function(v, selections) {
		if (!selections[0])
		    return;
		var rec = selections[0];
		render_docu(rec.data);
	    }
	}
    });

    Ext.create('Ext.container.Viewport', {
	layout: 'border',
	renderTo: Ext.getBody(),
	items: [
	    tree,
	    {
		xtype: 'tabpanel',
		title: 'Documentation',
		id: 'docview',
		region: 'center',
		margins: '5 5 5 0',
		layout: 'fit',
		items: []
	    }
	]
    });

});
