# UIFeedback
![last modified](https://img.shields.io/github/last-commit/AlbertoCuadra/UIFeedback)

Routine to create an App to get Feedback from your users/customers.

## Getting started

To keep the source email, source password, and recipients secure, encrypt the app by following this guide:

1. Update uifeedback_mlapp.mlapp: source, source password and recipients 
2. Export uifeedback_mlapp to uifeedback.m file
3. Encrypt uifeedback.m: run "pcode('uifeedback', '-inplace')"
4. Call feedback.p in your main app: run uifeedback.p

## Tips
- Create a new @gmail just for this purpose
- Use the same recipient as the source email (optional)

## Author:
- Alberto  Cuadra Lara
