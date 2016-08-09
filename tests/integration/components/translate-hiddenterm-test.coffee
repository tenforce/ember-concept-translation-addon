`import { test, moduleForComponent } from 'ember-qunit'`
`import hbs from 'htmlbars-inline-precompile'`

moduleForComponent 'translate-hiddenterm', 'Integration | Component | translate hiddenterm', {
  integration: true
}

test 'it renders', (assert) ->
  assert.expect 2

  # Set any properties with @set 'myProperty', 'value'
  # Handle any actions with @on 'myAction', (val) ->

  @render hbs """{{translate-hiddenterm}}"""

  assert.equal @$().text().trim(), ''

  # Template block usage:
  @render hbs """
    {{#translate-hiddenterm}}
      template block text
    {{/translate-hiddenterm}}
  """

  assert.equal @$().text().trim(), 'template block text'
