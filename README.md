# twig

## An experimental Elm project.

I'm interested in scraping Medium to produce summaries of their articles. There will be another accompanying repo with the scraping/server set-up. Feed in an article url, click 'Simplify' and it will pull out the most important bits.

## Trying it yourself
If you wish to see how the application works, simply clone this repo and its partner repository, twig_server. Run the server in shell from the twig_server directory with the command `python serve.py`, and compile the Elm code from the twig directory with the command `gulp`. Navigate in your browser to the index.html file (e.g. `Users/.../twig/dist/index.html`), and you will be running the application. 

## Post-Project Thoughts
Elm is a wonderful programming language, most of all because runtime exceptions are few and far between (even if you deliberately attempt to engineer them). It interfaces nicely with the small amount of JavaScript I wrote for the project, and the Elm Architecture is an explicit and intuitive starting point for structuring an application. The most unusual aspect of the language for me is functional markup, but even that becomes quite normal after some tinkering. I'm unsure of the overall scalability of Elm for a legitimate production-level application, but it certainly feels promising.
