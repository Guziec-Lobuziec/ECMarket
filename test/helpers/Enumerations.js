function define(name, value, where) {
    Object.defineProperty(where, name, {
        value:      value,
        writable: false,
        enumerable: true
    });
}

let AgreementEnumerations = {}
define('Status', {New: 0, Running: 1, Done: 2}, AgreementEnumerations);
define('AgreementEnumerations', AgreementEnumerations, exports);
