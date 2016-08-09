`import { test, moduleForComponent } from 'ember-qunit'`
`import hbs from 'htmlbars-inline-precompile'`

moduleForComponent 'translation-source', 'Integration | Component | translation source', {
  integration: true
}

test 'it renders', (assert) ->
  assert.expect 2

  # Set any properties with @set 'myProperty', 'value'
  # Handle any actions with @on 'myAction', (val) ->

  @render hbs """{{translation-source}}"""

  assert.equal @$().text().trim(), ''

  # Template block usage:
  @render hbs """
    {{#translation-source}}
      template block text
    {{/translation-source}}
  """

  assert.equal @$().text().trim(), 'template block text'
