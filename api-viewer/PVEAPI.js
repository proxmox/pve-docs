var clicmdhash = {
    GET: 'get',
    POST: 'create',
    PUT: 'set',
    DELETE: 'delete'
};

function cliusage(method, path) {
    return `<tr><td>&nbsp;</td></td><tr><td>CLI:</td><td>pvesh ${clicmdhash[method]} ${path}</td></tr></table>`;
}
