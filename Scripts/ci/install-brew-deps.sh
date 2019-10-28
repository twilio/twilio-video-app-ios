#!/bin/bash
set -x # Prints the command before executing it.

# Pin awscli at 1.16.120.
(brew list awscli && brew link awscli) || (brew update && brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/589ccd992cdaab98a4736a90af751e016c717685/Formula/awscli.rb)
# Pin maven at 3.6.0.
(brew list maven && brew link maven) || (brew update && brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/6c90cd9316bfd7741e6022304f0969b44b540de4/Formula/maven.rb)
