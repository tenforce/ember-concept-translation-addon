`import Ember from 'ember'`
`import SuggestionsManagerMixin from '../../../mixins/suggestions-manager'`
`import { module, test } from 'qunit'`

module 'Unit | Mixin | suggestions manager'

# Replace this with your real tests.
test 'it works', (assert) ->
  SuggestionsManagerObject = Ember.Object.extend SuggestionsManagerMixin
  subject = SuggestionsManagerObject.create()
  assert.ok subject
