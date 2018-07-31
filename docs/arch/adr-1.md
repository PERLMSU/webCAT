# Title: React via Typescript and GraphQL via Elixir
# Context
The current state of the project is extremely fragile. All testing of the
application is manual, there is close to zero documentation, and the entirety
of the client-side code is in a single file. Django and Python are an easy
set of technologies to work with, but there are more modern alternatives very
suitable for a project like this. In order to find stability, most of the
codebase must be upended or dug through in some way, so why not just rewrite it as I do?
# Decision
I've had a lot of success building applications using Typescript on the 
frontend and Elixir on the backend. React is a natural choice for the frontend,
and Elixir a natural choice for a web backend. The backend will provide a GraphQL
endpoint and traditional REST endpoints, following typical HATEOAS priciples.
# Status
Accepted. I am currently in complete control of the project, as my employers 
seem to want to be hands-off at this point, so long as I produce a great app.
# Consequences
A comprehensive rewrite is no small task. Comprehensive testing and documentation
will be of the utmost importance, further slowing work. Taking my time with this
task and doing it all correctly will pay its dividends though. Development speed
will slow but efficiency and stability will soar. Because I have to look through
the entirety of the source and analyze it all, I'll be able to make an ERD of the
database and clean up mistakes, as well as add opportunities for generification
of parts of the system.
