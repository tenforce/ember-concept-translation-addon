`import Ember from 'ember'`
`import SourceManagerMixin from '../../../mixins/source-manager'`
`import { module, test } from 'qunit'`

module 'Unit | Mixin | source manager'

# Replace this with your real tests.
test 'it works', (assert) ->
  SourceManagerObject = Ember.Object.extend SourceManagerMixin
  subject = SourceManagerObject.create()
  assert.ok subject
