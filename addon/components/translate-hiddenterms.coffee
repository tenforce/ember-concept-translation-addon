`import Ember from 'ember'`
`import layout from '../templates/components/translate-hiddenterms'`
`import TranslationsUtils from '../mixins/translations-utils'`
`import SourceSaverManager from '../mixins/source-saver-manager'`
`import TermManager from '../mixins/term-manager'`

TranslateHiddentermsComponent = Ember.Component.extend TranslationsUtils, SourceSaverManager, TermManager,
  layout: layout
  store: Ember.inject.service('store')
  uglyObserver: Ember.observer('concept.id', 'language', ->
    return unless @get('concept') and @get('language')
    @set('newTerm', @generateHiddenTerm())
  ).on('init')
  manageHiddenTermSaving: (term) ->
    term.save()
  removeHiddenTerm: (term, index) ->
    if index is 0
      Ember.run.next =>
        @$('.tabbable')[1]?.focus()
    else
      unless index is "new"
        index = +index-1
        @$(".tabbable")[index]?.focus()
    @get('hiddenTerms').removeObject(term)
    term.destroyRecord()
  newField: false
  actions:
    showNewField: ->
      @toggleProperty('newField')
    saveHiddenTerm: (term) ->
      @manageHiddenTermSaving(term)
    saveNewHiddenTerm: (term) ->
      @get('hiddenTerms').pushObject term
      @manageHiddenTermSaving(term).then =>
        newterm = @generateHiddenTerm()
        @set('newTerm', newterm)
        @set('newField', false)

    removeHiddenTerm: (term, index) ->
      @removeHiddenTerm(term, index)
    removeNewHiddenTerm: (term, index) ->
      @changeTermValue(term, "", false)
      term.set('source', null)
`export default TranslateHiddentermsComponent`
