`import Ember from 'ember'`
`import TranslationsUtilsMixin from '../../../mixins/translations-utils'`
`import { module, test } from 'qunit'`

module 'Unit | Mixin | translations utils'

# Replace this with your real tests.
test 'it works', (assert) ->
  TranslationsUtilsObject = Ember.Object.extend TranslationsUtilsMixin
  subject = TranslationsUtilsObject.create()
  assert.ok subject
