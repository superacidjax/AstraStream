[![Test
Coverage](https://api.codeclimate.com/v1/badges/54c840e53bfe60b19ef1/test_coverage)](https://codeclimate.com/repos/66f800ef715b39325ec20d90/test_coverage)

[![Maintainability](https://api.codeclimate.com/v1/badges/54c840e53bfe60b19ef1/maintainability)](https://codeclimate.com/repos/66f800ef715b39325ec20d90/maintainability)

### Required Environment Variables for non-local environments
* ```ENV["ASTRA_BASE_URL"]```
This is the base URL of the AstraApp's internal (non-public) endpoints.
* ```ENV["RAILS_MASTER_KEY"]```
This is the rails master key found outside of the repository, in config/master.key
* ```ENV["RUDDERSTACK_SEND"]``` Set this to ```"true"``` to send to Rudderstack.
  The default is false, except in the testing environment since Rudderstack is
mocked. Setting this to false is helpful for local development so we aren't
sending local people and events to Rudderstack/Snowflake/S3.
