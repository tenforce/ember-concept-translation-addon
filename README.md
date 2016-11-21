# Concept-translation-addon

This is an ember addon for the translation frontend (`git@git.tenforce.com:esco/translation-frontend.git`), for the translation tool.

## Usage

Add `{{concept-translation-addon concept=your.model defaultLang=your.language showQuest=false showSuggestions=false showSource=false showPlus=true showElements=false toggleButton=true showLanguageSelector=false showStatusSelector=false}}` to your hbs file to use the addon.

### Configurable elements
- `concept` the concept you want the translation for
- `defaultLang` default language for the language selector
- `showQuest` flag if you want to have a Quest button and keyboard shortcut or not
- `showSuggestions` flag if you want Suggestions or not
- `showSource` flag if you want Source or not
- `showPlus` flag if you want a + button to toggle the new non-pref and hidden term fields or not
- `showElements` flag if you want the 'term editor' to be hidden or not
- `toggleButton` flag if you want a header button. This button shows or hides the 'term editor'
- `showLanguageSelector` flag if you want a language selector or not
- `showStatusSelector` flag if you want a status selector or not
- `withoutTasks` flag if you want to disable tasks. By default it is false.

## Installation

`ember install git+ssh://git@git.tenforce.com:mu-semtech/concept-translation-addon.git`


concept-translation-addon

concept=model
defaultLang=user.language
showQuest=false
showSuggestions=true
showSource=true
showPlus=false
showElements=true
toggleButton=false
showLanguageSelector=true showStatusSelector=true defaultClasses=true showGendersBox=showGendersBox}}
