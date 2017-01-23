`import Ember from 'ember'`

TranslationsUtilsMixin = Ember.Mixin.create
  placeholder: "e.g., \"actress//sf\""
  emptyTerm: Ember.computed 'term.literalForm', ->
    if @get('term.literalForm') then return false
    else return true
  shouldHighlight: Ember.computed 'emptyTerm', 'termIsFocused', ->
    # if @get('emptyTerm') or @get('termIsFocused') then return true
    if @get('termIsFocused') then return true
    else return false
  termIsFocused: false
  parseRolesFromString: (term) ->
    literalform = term.get('literalForm')
    array = []
    split = literalform.split('//')
    genders = split[1]
    unless genders
      unless literalform.indexOf("//") is -1
        term.set('literalForm', literalform.replace("//", ""))
        term.set('literalFormValues.firstObject.content', literalform.replace("//", ""))
        return ['']
      return array
    unless genders.indexOf("sf") is -1 then array.push('standard female term')
    else unless genders.indexOf("f") is -1 then array.push('female')
    unless genders.indexOf('sm') is -1 then array.push('standard male term')
    else unless genders.indexOf('m') is -1 then array.push('male')
    unless genders.indexOf('n') is -1 then array.push('neutral')
    term.set('literalForm', split[0].trim())
    term.set('literalFormValues.firstObject.content', split[0].trim())
    return array
  changeTermValue: (term, value, trim) ->
    Ember.assert "term is undefined", term
    if trim then value = value.trim()
    term.set('literalForm', value)
    term.set('literalFormValues.firstObject.content', value)

  createQuestUrl: (text, source, target) ->
    text = escape(text)
    source = escape(source).toUpperCase()
    target = escape(target).toUpperCase()
    return "https://webgate.ec.testa.eu/questmetasearch/search.php?searchedText=#{text}&selectedSourceLang=#{source}&selectedDestLang=#{target}"

  actions:
    focusTerm: (bool) ->
      @set 'termIsFocused', bool

`export default TranslationsUtilsMixin`
