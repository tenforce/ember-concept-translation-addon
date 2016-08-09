`import { test, moduleForComponent } from 'ember-qunit'`
`import hbs from 'htmlbars-inline-precompile'`

moduleForComponent 'translation-suggestions', 'Integration | Component | translation suggestions', {
  integration: true
}

test 'it renders', (assert) ->
  assert.expect 2

  # Set any properties with @set 'myProperty', 'value'
  # Handle any actions with @on 'myAction', (val) ->

  @render hbs """{{translation-suggestions}}"""

  assert.equal @$().text().trim(), ''

  # Template block usage:
  @render hbs """
    {{#translation-suggestions}}
      template block text
    {{/translation-suggestions}}
  """

  assert.equal @$().text().trim(), 'template block text'
