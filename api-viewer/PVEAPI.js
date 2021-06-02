let method2cmd = {
    GET: 'get',
    POST: 'create',
    PUT: 'set',
    DELETE: 'delete'
};

function cliUsageRenderer(method, path) {
    return `<tr><td>&nbsp;</td></td><tr><td>CLI:</td><td>pvesh ${method2cmd[method]} ${path}</td></tr></table>`;
}
