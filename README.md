# Test Runner Orchestrator

An Orchestrator for Exercism's test runners

## Run in development

To run locally, you need to also clone https://github.com/exercism/test-runner-dev-invoker at the same level directory as this repo.

Once that's done:
- Populate `config/secrets.yml` with same sort of keys as your local website.
- Run `bundle install`
- Run `./bin/run.sh`

It will then sit and wait for messages from the website.

## Copyright

All content in this repository is Copyright to Exercism and licenced under MIT.
