{{#methods}}
// {{description}}
function {{name}}(assert) {
  {{{startTag}}}
  {{{snippet}}}
  {{{endTag}}}
}

{{/methods}}
//.cssg-methods-pragma

test("{{name}}", async function(assert) {
  {{#methods}}
  // {{description}}
  await {{name}}(assert)

  {{/methods}}
//.cssg-methods-pragma
})