# Net Worth Tracker

A simple application to keep track of your net worth.  Features include:

- Keeping track of current and historical account balances

- Viewing a graph of all historical balances

- Support for most asset types (equities, mutual funds, foreign currencies, etc).  All balances convert to your base currency.

# Infra

The code in this repository is deployed to Heroku, and several add-ons are used:

1. Postgres (database)
2. Memcachier (caching)
3. Keen.IO (user analytics)
4. NewRelic (server/request analytics)
5. SendGrid (outgoing emails)
6. Rollbar (exception monitoring)
7. Heroku Scheduler (task scheduling)

In addition, AWS S3 is used for persistent file storage.  Cloudflare is used in front of Heroku for site reliability.

# Disclaimer

This is still a WIP app.  Sorry in advance for any dirty code!

# How to Deploy

1. `rspec`
2. Commit your changes and merge the PR to master on GitHub
2. `checkout master` locally and run `git push heroku master`.
