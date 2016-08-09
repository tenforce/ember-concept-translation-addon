`import Ember from 'ember'`
`import layout from '../templates/components/translate-prefterm'`
`import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';`
`import TranslationsUtils from '../mixins/translations-utils'`
`import SuggestionsManager from '../mixins/suggestions-manager'`
`import SourceManager from '../mixins/source-manager'`
`import TermManager from '../mixins/term-manager'`

TranslatePreftermComponent = Ember.Component.extend KeyboardShortcuts, TranslationsUtils, SuggestionsManager, SourceManager, TermManager,
  layout: layout
  keyboardShortcuts:
    'ctrl+alt+d':
      action: 'deleteTerm'
      scoped: true
    'ctrl+alt+o':
      action: 'toggleSource'
      scoped: true
      preventDefault: true

  managePrefTermSaving: (term, save) ->
    promises = []
    termRoles = @parseRolesFromString(term)
    if termRoles.length > 0
      term.set('roles', [])
      @setGender(term, false, "neutral")
    termRoles.forEach (role) =>
      if ["standard female term", "standard male term"].contains role
        if role is "standard female term" then promises.push(@setAsPreferred(term, false, "female"))
        else if role is "standard male term" then promises.push(@setAsPreferred(term, false, "male"))
    Ember.RSVP.Promise.all(promises).then =>
      if save then term.save()

  actions:
    prefTermContentModified: (term, event) ->
      if(event.keyCode == 13 && not event.shiftKey)
        @managePrefTermSaving(term, true)
      else
        @changeTermValue(term, event, false)

`export default TranslatePreftermComponent`
