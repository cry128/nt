# NixTypes (nt)


## Conventions
1. Avoid the `with` keyword like your life depends on it!!
      Every LSP I've tried has handled them terribly. Not to mention it absolutely
      pollutes the scoped namespace ;-; Just stick to writing out `let ... in`. And **iff**
      you **absolutely** need it to condense code in a meaningful way, then isolate its
      use to a very **very** small scope. Not your entire file!
2. All names/identifiers should be written in **camelCase**, except *"Types"* (aka specifically structured attribute sets).
      Which should be written in **PascalCase**. **Typeclasses** should be written in **PascalCaseWithApostrophe'**.
