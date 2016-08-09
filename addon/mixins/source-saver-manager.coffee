`import Ember from 'ember'`

SourceSaverManagerMixin = Ember.Mixin.create
  actions:
    saveSource: (term) ->
      term.save()
    saveNewSource: (term) ->
      ## Nothing to do
      false


`export default SourceSaverManagerMixin`
