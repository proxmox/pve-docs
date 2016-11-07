//////////////////////////////////////////////////////////////////////////
// asciidoc JS helper for Proxmox VE mediawiki pages
//
// code based on original asciidoc.js, but re-written using jQuery
//
//////////////////////////////////////////////////////////////////////////

var asciidoc = {

    // toc generator
    toc: function ($content) {
	var tocholder = $content.find('#toc');

	if (!tocholder) {
	    return;
	}

	tocholder.html('');
	tocholder.hide();

	var html = "<div id=\"toctitle\"><h2>Contents</h2></div><ul>";

	var n = 0;
	$content.find("div.sect1").each(function(){
	    var h = jQuery(this).find("h2").first();
	    var id = h.attr("id");
	    if (id != null) {
		n++;
		html += "<li class=\"toclevel-1\">" +
		    "<a href=\"#" + id + "\">" +
		    "<span class=\"toctext\">" + h.html() +
		    "</span></a></li>";
	    }
	});

	html += "</ul>";

	if (n > 3) {
	    tocholder.html(html);
	    tocholder.show();
	}
    },

    // footnote generator
    footnotes: function ($content) {
	var noteholder = $content.find('#footnotes');
	if (!noteholder) {
	    return;
	}

	noteholder.html('');

	// Rebuild footnote entries.
	var refs = {};
	var n = 0;
	var inner_html = '';

	$content.find("span.footnote").each(function(){
	    n++;
	    var span = jQuery(this);
	    var note = span.attr("data-note");
	    var id = span.attr("id");
	    if (!note) {
		// Use [\s\S] in place of . so multi-line matches work.
		// Because JavaScript has no s (dotall) regex flag.
		note = span.html().match(/\s*\[([\s\S]*)]\s*/)[1];
		span.html("[<a id='_footnoteref_" + n + "' href='#_footnote_" +
			  n + "' title='View footnote' class='footnote'>" + n +
			  "</a>]");
		span.attr("data-note", note);
	    }
	    inner_html +=
            "<div class='footnote' id='_footnote_" + n + "'>" +
		"<a href='#_footnoteref_" + n + "' title='Return to text'>" +
		n + "</a>. " + note + "</div>";

	    if (id != null) { refs["#"+id] = n; }
	});

	if (inner_html) { noteholder.html("<hr>" + inner_html); }

	if (n != 0) {
	    // process footnoterefs.
	    $content.find("span.footnoteref").each(function(){
		var span = jQuery(this);
		var href = span.find("a").first().attr("href");
		href = href.match(/#.*/)[0];  // in case it return full URL.
		n = refs[href];
		span.html("[<a href='#_footnote_" + n +
			  "' title='View footnote' class='footnote'>" + n + "</a>]");
	    });
	}
    }
};

// add init to mediawiki resource loader queue
(window.RLQ=window.RLQ||[]).push(function(){
    mw.hook('wikipage.content').add(function($content) {
	asciidoc.toc($content);
	asciidoc.footnotes($content);
    });
});
