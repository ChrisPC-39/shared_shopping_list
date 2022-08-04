# Shared shopping list

Simple shared shopping list using Firebase, with no Auth. API keys are not public (make your own firebase_options).

## TODO

- Fix textfields not starting with capitalization (phone_main_screen and phone_comment_screen)
- Fix search function not working
- Fix adding/substracting items by pressing + or - giving users an epilepsy (due to setState(() {}))
- Vote to delete inside comment menu
- Delete/Edit comments (?)

## Issues

UI kind of sucks:
- IconButtons (to open chat) are next to every single bubble and it's very horrible looking
- - Can be fixed by opening comments tab when tapping on the item bubble, but how would anyone cross items off the list? 
- Holding on a bubble to vote to delete is kind of unintuitive. 
- - Can be fixed by swiping to vote (Dismissible()), but swiping and not deleting the item would result in an error in debug (or maybe just a warning?).
- Background is boring
- - Can be fixed by adding a background with a repeating pattern (similar to Whatsapp default backgrounds)
