var COS = require('cos-nodejs-sdk-v5');
var cos = new COS({
  SecretId: 'COS_SECRETID',
  SecretKey: 'COS_SECRETKEY'
});

{{#methods}}
// {{description}}
function {{name}}() {
  {{{startTag}}}
  {{{snippet}}}
  {{{endTag}}}
}

{{/methods}}
//.cssg-methods-pragma

describe("{{name}}", function() {
  {{#methods}}
  // {{description}}
  it("{{name}}", function() {
    return {{name}}()
  })

  {{/methods}}
  //.cssg-methods-pragma
})