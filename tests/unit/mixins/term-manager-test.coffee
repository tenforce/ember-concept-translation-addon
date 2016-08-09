`import Ember from 'ember'`
`import TermManagerMixin from '../../../mixins/term-manager'`
`import { module, test } from 'qunit'`

module 'Unit | Mixin | term manager'

# Replace this with your real tests.
test 'it works', (assert) ->
  TermManagerObject = Ember.Object.extend TermManagerMixin
  subject = TermManagerObject.create()
  assert.ok subject
