`import Ember from 'ember'`
`import layout from '../templates/components/translate-altterm'`
`import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';`
`import TranslationsUtils from '../mixins/translations-utils'`
`import SuggestionsManager from '../mixins/suggestions-manager'`
`import SourceManager from '../mixins/source-manager'`
`import TermManager from '../mixins/term-manager'`

TranslateAlttermComponent =  Ember.Component.extend KeyboardShortcuts, TranslationsUtils, SuggestionsManager, SourceManager, TermManager,
  layout: layout
  keyboardShortcuts:
    'ctrl+alt+q':
      action: 'goToQuestUrl'
      scoped: true
    'ctrl+alt+d':
      action: 'deleteTerm'
      scoped: true
    'ctrl+alt+o':
      action: 'toggleSource'
      scoped: true
      preventDefault: true

  pathToQuest: Ember.computed 'term.literalForm', ->
    term = @get('term')
    if term.get('literalForm')
      target = @get('targetLanguage')
      source = "en"
      text = term.get('literalForm')
      return @createQuestUrl(text, source, target)
    return @createQuestUrl("", source, target)

  actions:
    goToQuestUrl: ->
      window.open(@get('pathToQuest'))

    altTermContentModified: (term, event) ->
      if(event.keyCode == 13 && not event.shiftKey)
        @changeTermValue(term, event, true)
        @sendAction('saveAltTerm', term)
      else
        @changeTermValue(term, event, false)
    removeAltTerm: (term, index) ->
      @sendAction('removeAltTerm', term, index)
    deleteTerm: ->
      term = @get('term')
      if term.get('literalForm')
        event=
          target:
            value: ''
        @changeTermValue(term, event, false)
        term.set('source', '')
        term.save()
      else
        @sendAction('removeAltTerm', term, @get('index'))

`export default TranslateAlttermComponent`
