`import Ember from 'ember'`

TranslationsUtilsMixin = Ember.Mixin.create
  placeholder: "Use double forward slash ('//') to add gender and press ENTER"
  emptyTerm: Ember.computed 'term.literalForm', ->
    if @get('term.literalForm') then return false
    else return true
  shouldHighlight: Ember.computed 'emptyTerm', 'termIsFocused', ->
    if @get('emptyTerm') or @get('termIsFocused') then return true
    else return false
  termIsFocused: false
  parseRolesFromString: (term) ->
    literalform = term.get('literalForm')
    array = []
    split = literalform.split('//')
    genders = split[1]
    unless genders then return array
    unless genders.indexOf("sf") is -1 then array.push('standard female term')
    else unless genders.indexOf("f") is -1 then array.push('female')
    unless genders.indexOf('sm') is -1 then array.push('standard male term')
    else unless genders.indexOf('m') is -1 then array.push('male')
    unless genders.indexOf('n') is -1 then array.push('neutral')
    term.set('literalForm', split[0].trim())
    term.set('literalFormValues.firstObject.content', split[0].trim())
    return array
  changeTermValue: (term, event, trim) ->
    Ember.assert "term is undefined", term
    if trim then value = event.target.value.trim()
    else value = event.target.value
    term.set('literalForm', value)
    term.set('literalFormValues.firstObject.content', value)
  actions:
    focusTerm: (bool) ->
      @set 'termIsFocused', bool
    changeTermValue: (term, event) ->
      @changeTermValue(term, event, false)
      return false
    deleteTerm: ->
      term = @get('term')
      event =
        target:
          value: ''
      @changeTermValue(term, event, false)
      term.set('source', '')
      #term.save()

`export default TranslationsUtilsMixin`