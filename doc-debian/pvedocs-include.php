<?php

# see http://www.mediawiki.org/wiki/Manual:Parser_functions

$wgExtensionCredits['parserhook'][] = array(
    'name' => "PVE Documenation Pages",
    'description' => "Display PVE Documentation Pages", 
    'author' => "Dietmar Maurer",
);
 
# Define a setup function
$wgHooks['ParserFirstCallInit'][] = 'efPvedocsParserFunction_Setup';

# Add a hook to initialise the magic word
$wgHooks['LanguageGetMagic'][] = 'efPvedocsParserFunction_Magic';
 
function efPvedocsParserFunction_Setup(&$parser) {
    # Set a function hook associating the "pvedocs" magic
    # word with our function
    $parser->setFunctionHook( 'pvedocs', 'efPvedocsParserFunction_Render' );
    return true;
}
 
function efPvedocsParserFunction_Magic(&$magicWords, $langCode) {
    # Add the magic word
    # The first array element is whether to be case sensitive,
    # in this case (0) it is not case sensitive, 1 would be sensitive
    # All remaining elements are synonyms for our parser function
    $magicWords['pvedocs'] = array( 0, 'pvedocs' );

    # unless we return true, other parser functions extensions won't get loaded.
    return true;
}

function encodeURI($uri) {
    return preg_replace_callback("{[^0-9a-z_.!~*'();,/?:@&=+$#-]}i",
        function ($m) { return sprintf('%%%02X', ord($m[0])); }, $uri);
}

function efPvedocsParserFunction_Render($parser, $param1 = '', $param2 = '') {

	$parser->disableCache();

    # only allow simply names, so that users can only include
    # files from within "/usr/share/pve-docs/"
	if (!preg_match("/[a-z0-9.-]+\.html/i", $param1)) {
        die("no such manual page");
	}   

	$content = file_get_contents("/usr/share/pve-docs/$param1");

    $output = "<noscript><div><p>" .
        "This page requires java-script. To view " .
        "this page without java-script goto " .
        "<a href='/pve-docs/$param1'>$param1</a>" .
        "</div></noscript>\n";

	# hack to inject html without modifications my mediawiki parser
	$encHtml = encodeURI($content);
	$output .= "<div id='pve_embed_data'></div>";
	$output .= "<script>" .
        "var data = decodeURI(\"".$encHtml."\");" .
        "document.getElementById('pve_embed_data').innerHTML = data;" .
        "</script>";
	
	return array($output, 'noparse' => true, 'isHTML' => true);
}

?>
