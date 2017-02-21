`import Ember from 'ember'`
`import layout from '../templates/components/translate-prefterm'`
`import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';`
`import TranslationsUtils from '../mixins/translations-utils'`
`import SuggestionsManager from '../mixins/suggestions-manager'`
`import SourceManager from '../mixins/source-manager'`
`import TermManager from '../mixins/term-manager'`

TranslatePreftermComponent = Ember.Component.extend KeyboardShortcuts, TranslationsUtils, SuggestionsManager, SourceManager, TermManager,
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

  showQuestIfNotEmpty: Ember.computed 'term.literalForm', ->
    if @get('term.literalForm') then return true else return false

  pathToQuest: Ember.computed 'term.literalForm', ->
    term = @get('term')
    target = @get('targetLanguage')
    source = "en"
    if term.get('literalForm')
      text = term.get('literalForm')
      return @createQuestUrl(text, source, target)
    else
      return ""


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

  saveField: ->
    term = @get('term')
    @sendAction('savePrefTerm', term)
    @set 'savedValue', term.get('literalForm')

  saveAllClick: ->
    @saveField()

  resetField: ->
    savedValue = @get 'savedValue'
    term = @get('term')
    @changeTermValue(term, savedValue, false)

  actions:
    saveField: ->
      @saveField()

    resetField: ->
      @resetField()

    toggleNeutral: (term) ->
      @setGender(term, true, 'neutral')
    removePrefTerm: (term, index) ->
      @sendAction('removePrefTerm', term, index)
    goToQuestUrl: ->
      if @get 'showQuest'
        url = @get('pathToQuest')
        if @get 'showQuestIfNotEmpty'
          window.open(url)

    prefTermContentModified: (term, event) ->
      if event.keyCode == 13 # Enter key
        @saveField()
      else
        @changeTermValue(term, event.target.value, false)




    deleteTerm: ->
      term = @get('term')
      @changeTermValue(term, '', false)
      term.set('source', null)
      if term.get('id') then term.save()

`export default TranslatePreftermComponent`
