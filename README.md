# Shared State Demo

This app is a simplified version of Ohanhi's [Shared State Demo](https://github.com/ohanhi/elm-shared-state).  Please consult his README to understand the logic behind the shared state architecture.

Note that in the Settings page, one can define a shared secret.  This is
an example of a child page updating the state of the parent.  The parent
state — the `SharedState` is visible in all child pages.  In the present
demo, the shared secret is displyed on the Home page.

Thus there is a
simple mechanism for a login page to ask for a session token by Http, then
share this token to other pages.  Consequently, using a template like the
present app, one can build a standard login system which can be used as
a souped-up template for app development.

I'll polish this demo up a bit but want to keep it simple.  Otherwise it is
not a template.

And three cheers to Ohanhi for this great design!


## Installation

For now: `elm make src/Main.elm --output=Main.js`.  The `elm reactor` and click on `index.html`
