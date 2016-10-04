`import Ember from 'ember'`
`import layout from '../templates/components/translate-hiddenterm'`
`import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';`
`import TranslationsUtils from '../mixins/translations-utils'`
`import SuggestionsManager from '../mixins/suggestions-manager'`
`import SourceManager from '../mixins/source-manager'`

TranslateHiddentermComponent = Ember.Component.extend KeyboardShortcuts, TranslationsUtils, SuggestionsManager, SourceManager,
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
  placeholder: "e.g., \"actress\" and confirm with ENTER"

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
  actions:
    goToQuestUrl: ->
      if @get 'showQuest'
        url = @get('pathToQuest')
        if @get 'showQuestIfNotEmpty'
          window.open(url)
    hiddenTermContentModified: (term, event) ->
      if(event.keyCode == 13 && not event.shiftKey)
        @changeTermValue(term, event, true)
        @sendAction('saveHiddenTerm', term)
      else
        @changeTermValue(term, event, false)

    removeHiddenTerm: (term, index) ->
      @sendAction('removeHiddenTerm', term, index)
    deleteTerm: ->
      term = @get('term')
      if term.get('literalForm')
        event=
          target:
            value: ''
        @changeTermValue(term, event, false)
        term.set('source', null)
        if term.get('id') then term.save()
      else
        @sendAction('removeHiddenTerm', term, @get('index'))


`export default TranslateHiddentermComponent`
