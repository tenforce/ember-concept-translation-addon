`import { test, moduleForComponent } from 'ember-qunit'`
`import hbs from 'htmlbars-inline-precompile'`

moduleForComponent 'translate-prefterm', 'Integration | Component | translate prefterm', {
  integration: true
}

test 'it renders', (assert) ->
  assert.expect 2

  # Set any properties with @set 'myProperty', 'value'
  # Handle any actions with @on 'myAction', (val) ->

  @render hbs """{{translate-prefterm}}"""

  assert.equal @$().text().trim(), ''

  # Template block usage:
  @render hbs """
    {{#translate-prefterm}}
      template block text
    {{/translate-prefterm}}
  """

  assert.equal @$().text().trim(), 'template block text'
