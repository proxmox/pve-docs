<?php
// see http://www.mediawiki.org/wiki/Manual:Parser_functions

class PVEDocs {
    public static function onParserFirstCallInit(Parser $parser ) {
        $parser->setFunctionHook('pvedocs', [ self::class, 'efPvedocsParserFunction_Render' ]);
        $parser->setHook('pvehide',  [ self::class, 'renderTagPveHideContent' ]);

        return true;
    }

    // similar code as in <htmlet> tag...
    public static function efPvedocsPostProcessFunction($parser, &$text) {
        $text = preg_replace_callback(
            '/<!--- @PVEDOCS_BASE64@ ([0-9a-zA-Z\\+\\/]+=*) @PVEDOCS_BASE64@ -->/sm',
            function ($m) { return base64_decode("$m[1]"); },
                $text
        );
        return true;
    }

    // "Render" <pvehide>
    public static function renderTagPveHideContent($input, array $args, Parser $parser, PPFrame $frame ) {
        return ''; // simply return nothing
    }


    # Render the output of {{#pvedocs:chapter}}.
    public static function efPvedocsParserFunction_Render(Parser $parser, $doc = '') {
        $parser->getOutput()->updateCacheExpiry(0); // disableCache() was dropped in MW 1.34

        // only allow simple names, so that just files from within "/usr/share/pve-docs/" can be included
        if (!preg_match("/^(?:\.?[a-z0-9-]+)+\.html$/i", $doc)) {
            return array("Error: tried to include bad file name '$doc'", 'noparse' => true, 'isHTML' => false);
        }

        $docPath = "/usr/share/pve-docs/$doc";
        if (!file_exists($docPath)) {
            return array("File not found: $doc", 'noparse' => true, 'isHTML' => false);
        }

        // load JS helper for TOC/footnote generation and load actual HTML content fom docs
        $content = "\n<script type=\"text/javascript\">\n".file_get_contents("/usr/lib/pve-docs/PVEDocs/mw-asciidoc.js") ."</script>";

        $content .= file_get_contents($docPath);

        // from https://gerrit.wikimedia.org/r/plugins/gitiles/mediawiki/extensions/HTMLets/+/11e5ef1ea2820319458dc67174ca76d6e00b10cc/HTMLets.php#140
        $output = '<!--- @PVEDOCS_BASE64@ '.base64_encode($content).' @PVEDOCS_BASE64@ -->';
        return array($output, 'noparse' => true, 'isHTML' => true);
    }
}
