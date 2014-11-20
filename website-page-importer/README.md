website-page-importer
======================

Uses the NationBuilder gem (nationbuilder-rb - with a monkeypatch found here: https://github.com/dstockdale/nationbuilder-rb/commit/2edb165196e3796d277279e3434cfe22c9a8e1a4 to return full response) and token authentication to import different page types into a nation from a CSV. 

The files here are meant to be run as scripts from the command line, with shared methods kept in nb.rb and nation specifics (slugs, token) kept in config.rb.

CSV's provided for these scripts are expected to be encoded in UTF-8.

Currently can be used for:
- blog page imports
- basic page imports
- update signup profiles
- upload page attachments
- event page imports

Required parameters can be found in NationBuilders API documentation here: http://nationbuilder.com/api_documentation
