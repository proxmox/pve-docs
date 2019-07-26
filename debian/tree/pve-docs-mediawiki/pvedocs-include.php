<?php

# see http://www.mediawiki.org/wiki/Manual:Parser_functions

$wgExtensionCredits['parserhook'][] = array(
    'name' => "PVE Documentation Pages",
    'description' => "Display PVE Documentation Pages",
    'author' => "Dietmar Maurer",
);

# Define a setup function
$wgHooks['ParserFirstCallInit'][] = 'efPvedocsParserFunction_Setup';
$wgHooks['ParserAfterTidy'][] = 'efPvedocsPostProcessFunction';

# Add a hook to initialise the magic word
$wgHooks['LanguageGetMagic'][] = 'efPvedocsParserFunction_Magic';

function efPvedocsParserFunction_Setup(&$parser) {
    # Set a function hook associating the "pvedocs" magic
    # word with our function
    $parser->setFunctionHook('pvedocs', 'efPvedocsParserFunction_Render');

    $parser->setHook('pvehide', 'renderTagPveHideContent');

    return true;
}

# similar code as in <htmlet> tag...
function efPvedocsPostProcessFunction($parser, &$text) {
	$text = preg_replace_callback(
		'/<!--- @PVEDOCS_BASE64@ ([0-9a-zA-Z\\+\\/]+=*) @PVEDOCS_BASE64@ -->/sm',
		function ($m) {	return base64_decode("$m[1]"); },
		$text);

	return true;
}

// Render <pvehide>
function renderTagPveHideContent($input, array $args, Parser $parser,
PPFrame $frame ) {
    // simply return nothing
    return '';
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

function efPvedocsParserFunction_Render($parser, $param1 = '', $param2 = '') {

	$parser->disableCache();

    # only allow simply names, so that users can only include
    # files from within "/usr/share/pve-docs/"
	if (!preg_match("/[a-z0-9.-]+\.html/i", $param1)) {
        die("no such manual page");
	}

	$content = file_get_contents("/usr/share/pve-docs/$param1");

    # from https://gerrit.wikimedia.org/r/plugins/gitiles/mediawiki/extensions/HTMLets/+/11e5ef1ea2820319458dc67174ca76d6e00b10cc/HTMLets.php#140
    $output = '<!--- @PVEDOCS_BASE64@ '.base64_encode($content).' @PVEDOCS_BASE64@ -->';
    return array($output, 'noparse' => true, 'isHTML' => true);
}

?>
