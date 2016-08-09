`import { test, moduleForComponent } from 'ember-qunit'`
`import hbs from 'htmlbars-inline-precompile'`

moduleForComponent 'translate-hiddenterms', 'Integration | Component | translate hiddenterms', {
  integration: true
}

test 'it renders', (assert) ->
  assert.expect 2

  # Set any properties with @set 'myProperty', 'value'
  # Handle any actions with @on 'myAction', (val) ->

  @render hbs """{{translate-hiddenterms}}"""

  assert.equal @$().text().trim(), ''

  # Template block usage:
  @render hbs """
    {{#translate-hiddenterms}}
      template block text
    {{/translate-hiddenterms}}
  """

  assert.equal @$().text().trim(), 'template block text'
