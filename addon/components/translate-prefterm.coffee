`import Ember from 'ember'`
`import layout from '../templates/components/translate-prefterm'`
`import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';`
`import TranslationsUtils from '../mixins/translations-utils'`
`import SuggestionsManager from '../mixins/suggestions-manager'`
`import SourceManager from '../mixins/source-manager'`
`import TermManager from '../mixins/term-manager'`

TranslatePreftermComponent = Ember.Component.extend KeyboardShortcuts, TranslationsUtils, SuggestionsManager, SourceManager, TermManager,
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

  managePrefTermSaving: (term, save) ->
    promises = []
    termRoles = @parseRolesFromString(term)
    if termRoles.length > 0
      term.set('roles', [])
      promises.push(@setGender(term, false, "neutral"))
    termRoles.forEach (role) =>
      if ["standard female term", "standard male term"].contains role
        if role is "standard female term" then promises.push(@setAsPreferred(term, false, "female", true))
        else if role is "standard male term" then promises.push(@setAsPreferred(term, false, "male", true))
    Ember.RSVP.Promise.all(promises).then =>
      if save then term.save()

  actions:
    goToQuestUrl: ->
      if @get 'showQuest'
        url = @get('pathToQuest')
        if @get 'showQuestIfNotEmpty'
          window.open(url)
    prefTermContentModified: (term, event) ->
      if(event.keyCode == 13 && not event.shiftKey)
        @managePrefTermSaving(term, true)
      else
        @changeTermValue(term, event, false)
    deleteTerm: ->
      term = @get('term')
      event =
        target:
          value: ''
      @changeTermValue(term, event, false)
      term.set('source', null)
      if term.get('id') then term.save()

`export default TranslatePreftermComponent`
