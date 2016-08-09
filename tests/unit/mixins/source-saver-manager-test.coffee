`import Ember from 'ember'`
`import SourceSaverManagerMixin from '../../../mixins/source-saver-manager'`
`import { module, test } from 'qunit'`

module 'Unit | Mixin | source saver manager'

# Replace this with your real tests.
test 'it works', (assert) ->
  SourceSaverManagerObject = Ember.Object.extend SourceSaverManagerMixin
  subject = SourceSaverManagerObject.create()
  assert.ok subject
