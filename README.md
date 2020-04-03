# Pronto runner for flake8
[![Gem Version](https://badge.fury.io/rb/pronto-flake8.svg)](http://badge.fury.io/rb/pronto-flake8)
[![Build Status](https://travis-ci.org/scoremedia/pronto-flake8.svg?branch=master)](https://travis-ci.org/scoremedia/pronto-flake8)
[![Code Climate](https://codeclimate.com/github/scoremedia/pronto-flake8/badges/gpa.svg)](https://codeclimate.com/github/scoremedia/pronto-flake8)
[![Test Coverage](https://codeclimate.com/github/scoremedia/pronto-flake8/badges/coverage.svg)](https://codeclimate.com/github/scoremedia/pronto-flake8/coverage)
[![Dependency Status](https://gemnasium.com/badges/github.com/scoremedia/pronto-flake8.svg)](https://gemnasium.com/github.com/scoremedia/pronto-flake8)


Pronto runner for [flake8](http://flake8.pycqa.org/en/latest/), a Python Style Guide Enforcer. [What is Pronto?](https://github.com/mmozuras/pronto)


## Configuration of pronto-flake8
* `flake8` should be in your path or virtual environment.
* pronto-flake8 can be configured by placing a `.pronto_flake8.yml` inside the directory where pronto is run.




Following options are available:

| Option               | Meaning                                | Default                                   |
| -------------------- | -------------------------------------- | ----------------------------------------- |
| flake8_executable      | flake8 executable to call.               | `flake8` (calls `flake8` in `PATH`)           |


Example configuration to call custom flake8 executable:

```yaml
# .pronto_flake8.yml
flake8_executable: '/my/custom/path/flake8'
```

## Contribution Guidelines
### Installation
`git clone` this repo and `cd pronto-flake8`



Ruby
```sh
brew install cmake # or your OS equivalent
brew install rbenv # or your OS equivalent
rbenv install 2.5.7
rbenv global 2.5.7 # or make it project specific
gem install bundle
gem install pronto
bundle install
```

Python
```sh

virtualenv venv # tested on Python 3.6
source venv/bin/activate
pip install -r requirements.txt
```

### Instructions for maintainers
```sh
git checkout -b <new_feature> # or for core maintainer, just pull master after accepting merge
# make your changes
bundle exec rspec
# Update the version in `lib/pronto/flake8/version.rb` to the next version
* gem build pronto-flake8.gemspec
* gem install pronto-flake8-<current_version>.gem # get it from lib/pronto/flake8/version.rb 
# uncomment the line in dummy_package/dummy.py
pronto run --unstaged
```

It should show
```sh
dummy_package/dummy.py:1 E: E731 do not assign a lambda expression, use a def
```

* Recomment the line in dummy_package/dummy.py

## Publish
```
export VERSION=<gem version>
export TAG="v$VERSION"
git pull
git tag -a $TAG -m $TAG
git show $TAG
git push origin $TAG
```