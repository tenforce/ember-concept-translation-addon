`import { test, moduleForComponent } from 'ember-qunit'`
`import hbs from 'htmlbars-inline-precompile'`

moduleForComponent 'translate-prefterms', 'Integration | Component | translate prefterms', {
  integration: true
}

test 'it renders', (assert) ->
  assert.expect 2

  # Set any properties with @set 'myProperty', 'value'
  # Handle any actions with @on 'myAction', (val) ->

  @render hbs """{{translate-prefterms}}"""

  assert.equal @$().text().trim(), ''

  # Template block usage:
  @render hbs """
    {{#translate-prefterms}}
      template block text
    {{/translate-prefterms}}
  """

  assert.equal @$().text().trim(), 'template block text'
