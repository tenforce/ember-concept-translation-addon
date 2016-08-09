`import { test, moduleForComponent } from 'ember-qunit'`
`import hbs from 'htmlbars-inline-precompile'`

moduleForComponent 'translate-altterm', 'Integration | Component | translate altterm', {
  integration: true
}

test 'it renders', (assert) ->
  assert.expect 2

  # Set any properties with @set 'myProperty', 'value'
  # Handle any actions with @on 'myAction', (val) ->

  @render hbs """{{translate-altterm}}"""

  assert.equal @$().text().trim(), ''

  # Template block usage:
  @render hbs """
    {{#translate-altterm}}
      template block text
    {{/translate-altterm}}
  """

  assert.equal @$().text().trim(), 'template block text'
