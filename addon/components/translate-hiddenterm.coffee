`import Ember from 'ember'`
`import layout from '../templates/components/translate-hiddenterm'`
`import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';`
`import TranslationsUtils from '../mixins/translations-utils'`
`import SuggestionsManager from '../mixins/suggestions-manager'`
`import SourceManager from '../mixins/source-manager'`

TranslateHiddentermComponent = Ember.Component.extend KeyboardShortcuts, TranslationsUtils, SuggestionsManager, SourceManager,
  saveAllButton: Ember.inject.service()

  layout: layout
  keyboardShortcuts: Ember.computed 'disableShortcuts', ->
    if @get('disableShortcuts') then return {}
    else
      obj=
        {
          'ctrl+alt+d':
            action: 'deleteTerm'
            scoped: true
          'ctrl+alt+o':
            action: 'toggleSource'
            scoped: true
            preventDefault: true
        }
      if @get('showQuest')
        obj['ctrl+alt+q']=
          action: 'goToQuestUrl'
          scoped: true
      obj

  pathToQuest: Ember.computed 'term.literalForm', ->
    term = @get('term')
    target = @get('targetLanguage')
    source = "en"
    if term.get('literalForm')
      text = term.get('literalForm')
      return @createQuestUrl(text, source, target)
    else
      return ""

  showQuestIfNotEmpty: Ember.computed 'term.literalForm', ->
    if @get('term.literalForm') then return true else return false

  init: ->
    @_super()
    value = @get 'term.literalForm'
    @set 'savedValue', value
    @get('saveAllButton').subscribe(@)

  dirty: Ember.computed 'term.literalForm', 'savedValue', ->
    boundValue = @get('term.literalForm')
    savedValue = @get('savedValue')
    boundValue != savedValue

  savedValue: undefined

  # Reset the savedValue when the term is swapped. In particular when adding a new term. 
  newTermObserver: Ember.observer 'term', ->
    @set('savedValue', @get('term.literalForm'))

  saveField: ->
    term = @get('term')
    @sendAction('saveHiddenTerm', term)
    @set 'savedValue', term.get('literalForm')

  saveAllClick: ->
    @saveField()



  actions:
    saveField: ->
      @saveField()

    resetField: ->
      savedValue = @get 'savedValue'
      term = @get('term')
      @changeTermValue(term, savedValue, false)


    goToQuestUrl: ->
      if @get 'showQuest'
        url = @get('pathToQuest')
        if @get 'showQuestIfNotEmpty'
          window.open(url)

    hiddenTermContentModified: (term, event) ->
      @changeTermValue(term, event.target.value, false)

    removeHiddenTerm: (term, index) ->
      @sendAction('removeHiddenTerm', term, index)
    deleteTerm: ->
      term = @get('term')
      if term.get('literalForm')
        @changeTermValue(term, '', false)
        term.set('source', null)
        if term.get('id') then term.save()
      else
        @sendAction('removeHiddenTerm', term, @get('index'))


`export default TranslateHiddentermComponent`
