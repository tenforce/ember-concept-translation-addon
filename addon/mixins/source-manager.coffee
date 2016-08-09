`import Ember from 'ember'`

SourceManagerMixin = Ember.Mixin.create
  displaySource: false
  actions:
    saveSource: (term) ->
      @sendAction('saveSource', term)
      Ember.run.next =>
        @$('.tabbable')[0]?.focus()
    toggleSource: ->
      @toggleProperty('displaySource')

`export default SourceManagerMixin`
